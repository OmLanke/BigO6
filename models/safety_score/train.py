import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error, explained_variance_score
from sklearn.metrics import mean_absolute_percentage_error, max_error
from sklearn.feature_selection import SelectKBest, f_regression
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
from scipy import stats
from collections import Counter
import os
warnings.filterwarnings('ignore')

# Set matplotlib style for better plots
plt.style.use('seaborn-v0_8')
sns.set_palette("husl")

class TouristSafetyPredictor:
    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.feature_selector = None
        self.feature_names = None
        self.target_column = 'composite_safety_score'
        
    def load_and_prepare_data(self, data_path=None, df=None):
        """Load and prepare the dataset"""
        if df is not None:
            self.df = df.copy()
        else:
            self.df = pd.read_csv(data_path)
        
        print(f"Dataset shape: {self.df.shape}")
        print(f"Missing values:\n{self.df.isnull().sum().sum()}")
        
        # Handle missing values
        numeric_columns = self.df.select_dtypes(include=[np.number]).columns
        self.df[numeric_columns] = self.df[numeric_columns].fillna(self.df[numeric_columns].median())
        
        return self.df
    
    def feature_engineering(self):
        """Create additional features for better prediction"""
        df = self.df.copy()
        
        # Create derived features
        df['total_natural_disasters'] = (df['flood_events'] + df['landslide_events'] + 
                                       df['earthquake_events'] + df['cyclone_events'])
        
        df['infrastructure_index'] = (df['hospitals_per_100k'] + df['police_stations_per_100k'] + 
                                    df['fire_stations_per_100k']) / 3
        
        df['connectivity_score'] = (df['mobile_network_coverage_percent'] + 
                                  df['internet_connectivity_percent'] + 
                                  df['road_connectivity_index']) / 3
        
        df['weather_severity'] = df['extreme_weather_days'] * df['rainfall_variability_coefficient']
        
        df['crime_severity'] = (df['murder_cases'] * 5 + df['rape_cases'] * 4 + 
                              df['kidnapping_cases'] * 3 + df['robbery_cases'] * 2 + 
                              df['theft_cases']) / df['population'] * 100000
        
        # Population density (if area information available, otherwise use as proxy)
        df['population_density'] = df['population'] / 100  # Normalized
        
        return df
    
    def select_features(self, df):
        """Select relevant features for prediction"""
        # Define feature categories
        crime_features = [
            'total_crimes', 'crime_rate_per_100k', 'murder_cases', 'rape_cases',
            'kidnapping_cases', 'robbery_cases', 'theft_cases', 'burglary_cases',
            'fraud_cases', 'domestic_violence_cases', 'crimes_against_women',
            'crimes_against_tourists', 'crime_severity'
        ]
        
        natural_hazard_features = [
            'flood_events', 'flood_affected_population', 'landslide_events',
            'landslide_affected_population', 'earthquake_events', 'max_earthquake_magnitude',
            'lightning_strikes', 'forest_fires', 'cyclone_events', 'total_natural_disasters'
        ]
        
        transport_features = [
            'road_accidents', 'road_fatalities', 'road_injuries',
            'railway_accidents', 'aviation_incidents', 'emergency_response_time_minutes'
        ]
        
        infrastructure_features = [
            'hospitals_per_100k', 'police_stations_per_100k', 'fire_stations_per_100k',
            'mobile_network_coverage_percent', 'internet_connectivity_percent',
            'road_connectivity_index', 'power_supply_reliability_percent',
            'infrastructure_index', 'connectivity_score'
        ]
        
        climate_features = [
            'annual_rainfall_mm', 'rainfall_variability_coefficient',
            'max_temperature_celsius', 'min_temperature_celsius',
            'extreme_weather_days', 'monsoon_onset_deviation_days', 'weather_severity'
        ]
        
        other_features = ['population', 'population_density', 'year']
        
        # Combine all features
        selected_features = (crime_features + natural_hazard_features + transport_features + 
                           infrastructure_features + climate_features + other_features)
        
        # Keep only features that exist in the dataset
        selected_features = [f for f in selected_features if f in df.columns]
        
        return selected_features
    
    def train_model(self, df=None, target_col=None, test_size=0.2):
        """Train multiple models and select the best one"""
        if df is None:
            df = self.feature_engineering()
        
        if target_col:
            self.target_column = target_col
            
        # Select features
        feature_columns = self.select_features(df)
        self.feature_names = feature_columns
        
        X = df[feature_columns]
        y = df[self.target_column]
        
        # Validate and constrain target values to 0-100 range
        print(f"Target variable range before clipping: {y.min():.2f} to {y.max():.2f}")
        y = np.clip(y, 0, 100)
        print(f"Target variable range after clipping: {y.min():.2f} to {y.max():.2f}")
        
        # Split the data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42, stratify=None
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Feature selection
        self.feature_selector = SelectKBest(score_func=f_regression, k=min(15, len(feature_columns)))
        X_train_selected = self.feature_selector.fit_transform(X_train_scaled, y_train)
        X_test_selected = self.feature_selector.transform(X_test_scaled)
        
        # Train multiple models
        models = {
            'Random Forest': RandomForestRegressor(n_estimators=100, random_state=42),
            'Gradient Boosting': GradientBoostingRegressor(random_state=42),
            'Linear Regression': LinearRegression()
        }
        
        best_score = -np.inf
        best_model_name = None
        results = {}
        
        for name, model in models.items():
            # Cross-validation
            cv_scores = cross_val_score(model, X_train_selected, y_train, cv=5, scoring='r2')
            
            # Fit and evaluate
            model.fit(X_train_selected, y_train)
            y_pred = model.predict(X_test_selected)
            
            mse = mean_squared_error(y_test, y_pred)
            r2 = r2_score(y_test, y_pred)
            mae = mean_absolute_error(y_test, y_pred)
            
            # Additional evaluation metrics
            rmse = np.sqrt(mse)
            try:
                mape = mean_absolute_percentage_error(y_test, y_pred)
            except:
                mape = np.mean(np.abs((y_test - y_pred) / np.maximum(y_test, 1e-8))) * 100
            
            max_err = max_error(y_test, y_pred)
            explained_var = explained_variance_score(y_test, y_pred)
            
            results[name] = {
                'model': model,
                'cv_mean': cv_scores.mean(),
                'cv_std': cv_scores.std(),
                'test_r2': r2,
                'test_mse': mse,
                'test_rmse': rmse,
                'test_mae': mae,
                'test_mape': mape,
                'test_max_error': max_err,
                'explained_variance': explained_var,
                'predictions': y_pred,
                'y_test': y_test
            }
            
            if cv_scores.mean() > best_score:
                best_score = cv_scores.mean()
                best_model_name = name
                self.model = model
        
        # Store test data for evaluation
        self.X_test = X_test_selected
        self.y_test = y_test
        self.results = results
        
        # Print comprehensive model performance statistics
        self.print_detailed_stats()
        
        print(f"\n🏆 Best Model: {best_model_name}")
        return results
    
    def print_detailed_stats(self):
        """Print comprehensive model evaluation statistics"""
        print("\n" + "="*80)
        print("📊 COMPREHENSIVE MODEL EVALUATION STATISTICS")
        print("="*80)
        
        for name, result in self.results.items():
            print(f"\n🔍 {name.upper()} MODEL PERFORMANCE:")
            print("-" * 60)
            
            # Basic metrics
            print(f"📈 Cross-Validation R² Score: {result['cv_mean']:.4f} (±{result['cv_std']*2:.4f})")
            print(f"📊 Test Set Performance:")
            print(f"   • R² Score (Coefficient of Determination): {result['test_r2']:.4f}")
            print(f"   • Explained Variance Score: {result['explained_variance']:.4f}")
            print(f"   • Mean Squared Error (MSE): {result['test_mse']:.4f}")
            print(f"   • Root Mean Squared Error (RMSE): {result['test_rmse']:.4f}")
            print(f"   • Mean Absolute Error (MAE): {result['test_mae']:.4f}")
            print(f"   • Mean Absolute Percentage Error (MAPE): {result['test_mape']:.2f}%")
            print(f"   • Maximum Error: {result['test_max_error']:.4f}")
            
            # Statistical analysis
            y_test = result['y_test']
            y_pred = result['predictions']
            residuals = y_test - y_pred
            
            print(f"\n📊 Statistical Analysis:")
            print(f"   • Prediction Range: {y_pred.min():.2f} - {y_pred.max():.2f}")
            print(f"   • Actual Range: {y_test.min():.2f} - {y_test.max():.2f}")
            print(f"   • Residual Mean: {residuals.mean():.4f}")
            print(f"   • Residual Std Dev: {residuals.std():.4f}")
            print(f"   • Residual Min/Max: {residuals.min():.4f} / {residuals.max():.4f}")
            
            # Correlation analysis
            correlation = np.corrcoef(y_test, y_pred)[0, 1]
            print(f"   • Pearson Correlation: {correlation:.4f}")
            
            # Percentage of predictions within certain error ranges
            abs_errors = np.abs(residuals)
            within_5 = (abs_errors <= 5).mean() * 100
            within_10 = (abs_errors <= 10).mean() * 100
            within_15 = (abs_errors <= 15).mean() * 100
            
            print(f"\n🎯 Prediction Accuracy:")
            print(f"   • Within ±5 points: {within_5:.1f}% of predictions")
            print(f"   • Within ±10 points: {within_10:.1f}% of predictions") 
            print(f"   • Within ±15 points: {within_15:.1f}% of predictions")
            
        # Create confusion matrix for classification version
        self.create_classification_analysis()
    
    def create_classification_analysis(self):
        """Create classification analysis by binning safety scores"""
        print(f"\n📋 CLASSIFICATION ANALYSIS (Risk Categories)")
        print("-" * 60)
        
        def score_to_category(score):
            if score >= 75:
                return "Very Safe"
            elif score >= 60:
                return "Safe"
            elif score >= 45:
                return "Moderate Risk"
            else:
                return "High Risk"
        
        # Get best model results
        best_model_name = max(self.results.keys(), key=lambda k: self.results[k]['test_r2'])
        best_result = self.results[best_model_name]
        
        y_test = best_result['y_test']
        y_pred = best_result['predictions']
        
        # Convert to categories
        y_test_cat = [score_to_category(score) for score in y_test]
        y_pred_cat = [score_to_category(score) for score in y_pred]
        
        # Create confusion matrix
        categories = ["Very High Risk", "High Risk", "Moderate Risk", "Safe", "Very Safe"]
        
        # Manual confusion matrix calculation
        confusion_matrix = {}
        for actual in categories:
            confusion_matrix[actual] = {}
            for predicted in categories:
                confusion_matrix[actual][predicted] = 0
        
        for actual, predicted in zip(y_test_cat, y_pred_cat):
            confusion_matrix[actual][predicted] += 1
        
        # Print confusion matrix
        print(f"\n🔍 Confusion Matrix for {best_model_name}:")
        print("\nActual \\ Predicted", end="")
        for cat in categories:
            print(f"{cat:>15}", end="")
        print()
        
        for actual in categories:
            print(f"{actual:<17}", end="")
            for predicted in categories:
                print(f"{confusion_matrix[actual][predicted]:>15}", end="")
            print()
        
        # Calculate classification accuracy
        correct_predictions = sum(confusion_matrix[cat][cat] for cat in categories)
        total_predictions = len(y_test_cat)
        classification_accuracy = correct_predictions / total_predictions * 100
        
        print(f"\n🎯 Classification Metrics:")
        print(f"   • Overall Classification Accuracy: {classification_accuracy:.2f}%")
        print(f"   • Correct Classifications: {correct_predictions}/{total_predictions}")
        
        # Category-wise precision and recall
        print(f"\n📊 Category-wise Performance:")
        for category in categories:
            # True positives
            tp = confusion_matrix[category][category]
            
            # False positives (predicted as this category but actually different)
            fp = sum(confusion_matrix[other][category] for other in categories if other != category)
            
            # False negatives (actually this category but predicted as different)
            fn = sum(confusion_matrix[category][other] for other in categories if other != category)
            
            # Calculate precision and recall
            precision = tp / (tp + fp) if (tp + fp) > 0 else 0
            recall = tp / (tp + fn) if (tp + fn) > 0 else 0
            f1 = 2 * precision * recall / (precision + recall) if (precision + recall) > 0 else 0
            
            print(f"   {category}:")
            print(f"     • Precision: {precision:.3f}")
            print(f"     • Recall: {recall:.3f}")
            print(f"     • F1-Score: {f1:.3f}")
        
        print("="*80)
    
    def get_feature_importance(self):
        """Get feature importance from the best model"""
        if self.model is None:
            print("Model not trained yet!")
            return None
        
        if self.feature_selector is None or self.feature_names is None:
            print("Feature selector or feature names not available!")
            return None
        
        if hasattr(self.model, 'feature_importances_'):
            # Get selected feature names
            selected_features = self.feature_selector.get_support()
            selected_feature_names = [self.feature_names[i] for i, selected in enumerate(selected_features) if selected]
            
            importances = self.model.feature_importances_
            feature_imp = pd.DataFrame({
                'feature': selected_feature_names,
                'importance': importances
            }).sort_values('importance', ascending=False)
            
            return feature_imp
        elif hasattr(self.model, 'coef_'):
            # For linear models, use absolute coefficients as importance
            selected_features = self.feature_selector.get_support()
            selected_feature_names = [self.feature_names[i] for i, selected in enumerate(selected_features) if selected]
            
            importances = np.abs(self.model.coef_)
            feature_imp = pd.DataFrame({
                'feature': selected_feature_names,
                'importance': importances
            }).sort_values('importance', ascending=False)
            
            return feature_imp
        else:
            print("Model doesn't have feature importance attribute")
            return None
    
    def print_model_comparison_summary(self):
        """Print a summary comparison table of all models"""
        if not hasattr(self, 'results') or not self.results:
            print("No model results available for comparison.")
            return
        
        print("\n" + "="*120)
        print("📋 MODEL COMPARISON SUMMARY TABLE")
        print("="*120)
        
        # Header
        header = f"{'Model':<20} {'CV R²':<12} {'Test R²':<12} {'RMSE':<12} {'MAE':<12} {'MAPE':<12} {'Max Error':<12} {'Accuracy±5':<12}"
        print(header)
        print("-" * 120)
        
        # Sort models by test R² score
        sorted_models = sorted(self.results.items(), key=lambda x: x[1]['test_r2'], reverse=True)
        
        for name, result in sorted_models:
            # Calculate accuracy within ±5 points
            residuals = result['y_test'] - result['predictions']
            accuracy_5 = (np.abs(residuals) <= 5).mean() * 100
            
            row = f"{name:<20} {result['cv_mean']:<12.4f} {result['test_r2']:<12.4f} {result['test_rmse']:<12.2f} {result['test_mae']:<12.2f} {result['test_mape']:<12.1f}% {result['test_max_error']:<12.1f} {accuracy_5:<12.1f}%"
            print(row)
        
        print("="*120)
        
        # Best model highlight
        best_model = sorted_models[0]
        print(f"🏆 BEST MODEL: {best_model[0]} with R² = {best_model[1]['test_r2']:.4f}")
        print("="*120)
    
    def generate_performance_report(self):
        """Generate a comprehensive performance report"""
        if not hasattr(self, 'results') or not self.results:
            print("No model results available for report generation.")
            return
        
        print("\n" + "="*100)
        print("📄 COMPREHENSIVE PERFORMANCE REPORT")
        print("="*100)
        
        # Get best model
        best_model_name = max(self.results.keys(), key=lambda k: self.results[k]['test_r2'])
        best_result = self.results[best_model_name]
        
        print(f"\n🏆 BEST PERFORMING MODEL: {best_model_name}")
        print("-" * 80)
        
        print(f"📊 Core Performance Metrics:")
        print(f"   • R² Score: {best_result['test_r2']:.4f} (Explains {best_result['test_r2']*100:.1f}% of variance)")
        print(f"   • RMSE: {best_result['test_rmse']:.2f} points")
        print(f"   • MAE: {best_result['test_mae']:.2f} points") 
        print(f"   • MAPE: {best_result['test_mape']:.1f}%")
        
        # Model interpretation
        if best_result['test_r2'] >= 0.95:
            interpretation = "Excellent"
        elif best_result['test_r2'] >= 0.90:
            interpretation = "Very Good"
        elif best_result['test_r2'] >= 0.80:
            interpretation = "Good"
        elif best_result['test_r2'] >= 0.70:
            interpretation = "Fair"
        else:
            interpretation = "Poor"
        
        print(f"\n🎯 Model Quality Assessment: {interpretation}")
        
        # Accuracy breakdown
        residuals = best_result['y_test'] - best_result['predictions']
        abs_errors = np.abs(residuals)
        
        within_1 = (abs_errors <= 1).mean() * 100
        within_3 = (abs_errors <= 3).mean() * 100
        within_5 = (abs_errors <= 5).mean() * 100
        within_10 = (abs_errors <= 10).mean() * 100
        
        print(f"\n📈 Prediction Accuracy Breakdown:")
        print(f"   • Within ±1 point:  {within_1:5.1f}% of predictions")
        print(f"   • Within ±3 points: {within_3:5.1f}% of predictions")
        print(f"   • Within ±5 points: {within_5:5.1f}% of predictions")
        print(f"   • Within ±10 points: {within_10:5.1f}% of predictions")
        
        # Risk category distribution
        def score_to_category(score):
            if score >= 75: return "Very Safe"
            elif score >= 60: return "Safe"
            elif score >= 45: return "Moderate Risk"
            else: return "High Risk"
        
        y_test_cat = [score_to_category(score) for score in best_result['y_test']]
        y_pred_cat = [score_to_category(score) for score in best_result['predictions']]
        
        from collections import Counter
        actual_dist = Counter(y_test_cat)
        pred_dist = Counter(y_pred_cat)
        
        print(f"\n📊 Risk Category Distribution:")
        print(f"{'Category':<15} {'Actual':<8} {'Predicted':<10}")
        print("-" * 35)
        for category in ["Very Safe", "Safe", "Moderate Risk", "High Risk", "Very High Risk"]:
            actual_count = actual_dist.get(category, 0)
            pred_count = pred_dist.get(category, 0)
            print(f"{category:<15} {actual_count:<8} {pred_count:<10}")
        
        # Model reliability assessment
        cv_score = best_result['cv_mean']
        cv_std = best_result['cv_std']
        reliability = "High" if cv_std < 0.02 else "Medium" if cv_std < 0.05 else "Low"
        
        print(f"\n⚡ Model Reliability: {reliability}")
        print(f"   • Cross-validation score: {cv_score:.4f} (±{cv_std:.4f})")
        print(f"   • Stability: {'Stable' if cv_std < 0.03 else 'Moderate' if cv_std < 0.06 else 'Unstable'}")
        
        print("\n" + "="*100)
    
    def create_comprehensive_visualizations(self, save_dir='model_visualizations'):
        """Create and save comprehensive model visualizations as images"""
        if not hasattr(self, 'results') or not self.results:
            print("No model results available for visualization.")
            return
        
        # Create directory for saving plots
        os.makedirs(save_dir, exist_ok=True)
        
        # Set up the plotting style
        plt.rcParams['figure.figsize'] = (15, 10)
        plt.rcParams['font.size'] = 12
        
        print(f"\n📊 Creating comprehensive visualizations...")
        print(f"📁 Saving plots to: {save_dir}/")
        
        # 1. Model Performance Comparison
        self._create_model_comparison_plot(save_dir)
        
        # 2. Prediction vs Actual plots for all models
        self._create_prediction_plots(save_dir)
        
        # 3. Residual analysis plots
        self._create_residual_plots(save_dir)
        
        # 4. Feature importance visualization
        self._create_feature_importance_plot(save_dir)
        
        # 5. Confusion matrix heatmap
        self._create_confusion_matrix_plot(save_dir)
        
        # 6. Error distribution plots
        self._create_error_distribution_plots(save_dir)
        
        # 7. Model statistics summary table as image
        self._create_statistics_table_image(save_dir)
        
        # 8. Risk category distribution
        self._create_risk_distribution_plot(save_dir)
        
        print(f"✅ All visualizations saved to {save_dir}/ directory")
    
    def _create_model_comparison_plot(self, save_dir):
        """Create model performance comparison chart"""
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle('Model Performance Comparison', fontsize=20, fontweight='bold')
        
        models = list(self.results.keys())
        
        # R² Scores
        r2_scores = [self.results[model]['test_r2'] for model in models]
        colors = ['#3498db', '#e74c3c', '#2ecc71']
        bars1 = ax1.bar(models, r2_scores, color=colors, alpha=0.8)
        ax1.set_title('R² Score Comparison', fontsize=14, fontweight='bold')
        ax1.set_ylabel('R² Score')
        ax1.set_ylim(0, 1)
        for bar, score in zip(bars1, r2_scores):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{score:.4f}', ha='center', va='bottom', fontweight='bold')
        
        # RMSE
        rmse_scores = [self.results[model]['test_rmse'] for model in models]
        bars2 = ax2.bar(models, rmse_scores, color=colors, alpha=0.8)
        ax2.set_title('RMSE Comparison (Lower is Better)', fontsize=14, fontweight='bold')
        ax2.set_ylabel('RMSE')
        for bar, score in zip(bars2, rmse_scores):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                    f'{score:.2f}', ha='center', va='bottom', fontweight='bold')
        
        # MAE
        mae_scores = [self.results[model]['test_mae'] for model in models]
        bars3 = ax3.bar(models, mae_scores, color=colors, alpha=0.8)
        ax3.set_title('MAE Comparison (Lower is Better)', fontsize=14, fontweight='bold')
        ax3.set_ylabel('MAE')
        for bar, score in zip(bars3, mae_scores):
            ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                    f'{score:.2f}', ha='center', va='bottom', fontweight='bold')
        
        # Cross-validation scores
        cv_means = [self.results[model]['cv_mean'] for model in models]
        cv_stds = [self.results[model]['cv_std'] for model in models]
        bars4 = ax4.bar(models, cv_means, yerr=cv_stds, color=colors, alpha=0.8, capsize=5)
        ax4.set_title('Cross-Validation R² Score', fontsize=14, fontweight='bold')
        ax4.set_ylabel('CV R² Score')
        ax4.set_ylim(0, 1)
        for bar, mean, std in zip(bars4, cv_means, cv_stds):
            ax4.text(bar.get_x() + bar.get_width()/2, bar.get_height() + std + 0.01,
                    f'{mean:.4f}±{std:.4f}', ha='center', va='bottom', fontweight='bold')
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/01_model_comparison.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Model comparison chart saved")
    
    def _create_prediction_plots(self, save_dir):
        """Create prediction vs actual plots for all models"""
        fig, axes = plt.subplots(1, 3, figsize=(18, 6))
        fig.suptitle('Predictions vs Actual Values', fontsize=20, fontweight='bold')
        
        for idx, (name, result) in enumerate(self.results.items()):
            ax = axes[idx]
            y_test = result['y_test']
            y_pred = result['predictions']
            
            # Scatter plot
            ax.scatter(y_test, y_pred, alpha=0.6, s=30, color=['#3498db', '#e74c3c', '#2ecc71'][idx])
            
            # Perfect prediction line
            min_val = min(y_test.min(), y_pred.min())
            max_val = max(y_test.max(), y_pred.max())
            ax.plot([min_val, max_val], [min_val, max_val], 'r--', lw=2, label='Perfect Prediction')
            
            # Calculate and display R²
            r2 = result['test_r2']
            ax.text(0.05, 0.95, f'R² = {r2:.4f}', transform=ax.transAxes, 
                   bbox=dict(boxstyle='round', facecolor='white', alpha=0.8),
                   fontsize=12, fontweight='bold')
            
            ax.set_xlabel('Actual Safety Score')
            ax.set_ylabel('Predicted Safety Score')
            ax.set_title(f'{name}', fontweight='bold')
            ax.grid(True, alpha=0.3)
            ax.legend()
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/02_predictions_vs_actual.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Prediction vs actual plots saved")
    
    def _create_residual_plots(self, save_dir):
        """Create residual analysis plots"""
        fig, axes = plt.subplots(2, 3, figsize=(18, 12))
        fig.suptitle('Residual Analysis', fontsize=20, fontweight='bold')
        
        for idx, (name, result) in enumerate(self.results.items()):
            y_test = result['y_test']
            y_pred = result['predictions']
            residuals = y_test - y_pred
            
            # Residuals vs Predicted
            ax1 = axes[0, idx]
            ax1.scatter(y_pred, residuals, alpha=0.6, s=30, color=['#3498db', '#e74c3c', '#2ecc71'][idx])
            ax1.axhline(y=0, color='red', linestyle='--', linewidth=2)
            ax1.set_xlabel('Predicted Values')
            ax1.set_ylabel('Residuals')
            ax1.set_title(f'{name} - Residuals vs Predicted')
            ax1.grid(True, alpha=0.3)
            
            # Residual distribution
            ax2 = axes[1, idx]
            ax2.hist(residuals, bins=30, alpha=0.7, color=['#3498db', '#e74c3c', '#2ecc71'][idx], edgecolor='black')
            ax2.axvline(x=0, color='red', linestyle='--', linewidth=2)
            ax2.set_xlabel('Residuals')
            ax2.set_ylabel('Frequency')
            ax2.set_title(f'{name} - Residual Distribution')
            ax2.grid(True, alpha=0.3)
            
            # Add statistics
            mean_residual = residuals.mean()
            std_residual = residuals.std()
            ax2.text(0.05, 0.95, f'Mean: {mean_residual:.3f}\nStd: {std_residual:.3f}', 
                    transform=ax2.transAxes, bbox=dict(boxstyle='round', facecolor='white', alpha=0.8),
                    fontsize=10, verticalalignment='top')
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/03_residual_analysis.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Residual analysis plots saved")
    
    def _create_feature_importance_plot(self, save_dir):
        """Create feature importance visualization"""
        feature_imp = self.get_feature_importance()
        if feature_imp is None:
            print("   ⚠ Feature importance not available")
            return
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(20, 10))
        fig.suptitle('Feature Importance Analysis', fontsize=20, fontweight='bold')
        
        # Top 15 features bar plot
        top_15 = feature_imp.head(15)
        colors = plt.cm.get_cmap('viridis')(np.linspace(0, 1, len(top_15)))
        bars = ax1.barh(range(len(top_15)), top_15['importance'], color=colors)
        ax1.set_yticks(range(len(top_15)))
        ax1.set_yticklabels(top_15['feature'])
        ax1.set_xlabel('Importance Score')
        ax1.set_title('Top 15 Most Important Features', fontweight='bold')
        ax1.grid(True, alpha=0.3, axis='x')
        
        # Add values on bars
        for i, (bar, value) in enumerate(zip(bars, top_15['importance'])):
            ax1.text(value + max(top_15['importance']) * 0.01, i, f'{value:.3f}', 
                    va='center', fontweight='bold')
        
        # Feature importance by category
        feature_categories = {
            'Crime': ['crime', 'murder', 'rape', 'theft', 'robbery', 'kidnapping', 'fraud', 'burglary'],
            'Natural Disasters': ['flood', 'landslide', 'earthquake', 'lightning', 'forest', 'cyclone'],
            'Infrastructure': ['hospital', 'police', 'fire', 'mobile', 'internet', 'road', 'power'],
            'Climate': ['rainfall', 'temperature', 'weather', 'monsoon'],
            'Other': ['population', 'year', 'emergency']
        }
        
        category_importance = {}
        for category, keywords in feature_categories.items():
            category_imp = 0
            for _, row in feature_imp.iterrows():
                if any(keyword in row['feature'].lower() for keyword in keywords):
                    category_imp += row['importance']
            category_importance[category] = category_imp
        
        # Category pie chart
        categories = list(category_importance.keys())
        values = list(category_importance.values())
        colors = ['#ff9999', '#66b3ff', '#99ff99', '#ffcc99', '#ff99cc']
        
        wedges, texts, autotexts = ax2.pie(values, labels=categories, autopct='%1.1f%%', 
                                          colors=colors, startangle=90)
        ax2.set_title('Feature Importance by Category', fontweight='bold')
        
        # Make percentage text bold
        for autotext in autotexts:
            autotext.set_fontweight('bold')
            autotext.set_color('white')
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/04_feature_importance.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Feature importance plots saved")
    
    def _create_confusion_matrix_plot(self, save_dir):
        """Create confusion matrix heatmap"""
        # Get best model results
        best_model_name = max(self.results.keys(), key=lambda k: self.results[k]['test_r2'])
        best_result = self.results[best_model_name]
        
        y_test = best_result['y_test']
        y_pred = best_result['predictions']
        
        def score_to_category(score):
            if score >= 75: return "Very Safe"
            elif score >= 60: return "Safe"
            elif score >= 45: return "Moderate Risk"
            else: return "High Risk"
        
        # Convert to categories
        y_test_cat = [score_to_category(score) for score in y_test]
        y_pred_cat = [score_to_category(score) for score in y_pred]
        
        categories = ["High Risk", "Moderate Risk", "Safe", "Very Safe"]
        
        # Create confusion matrix
        confusion_matrix = np.zeros((len(categories), len(categories)))
        for actual, predicted in zip(y_test_cat, y_pred_cat):
            actual_idx = categories.index(actual)
            predicted_idx = categories.index(predicted)
            confusion_matrix[actual_idx, predicted_idx] += 1
        
        # Create heatmap
        fig, ax = plt.subplots(figsize=(12, 10))
        
        # Calculate percentages
        confusion_matrix_pct = confusion_matrix / confusion_matrix.sum() * 100
        
        # Create heatmap with annotations
        sns.heatmap(confusion_matrix, annot=True, fmt='g', cmap='Blues', 
                   xticklabels=categories, yticklabels=categories, ax=ax,
                   square=True, linewidths=0.5, cbar_kws={"shrink": .8})
        
        ax.set_title(f'Confusion Matrix - {best_model_name}\n(Risk Category Classification)', 
                    fontsize=16, fontweight='bold', pad=20)
        ax.set_xlabel('Predicted Category', fontsize=12, fontweight='bold')
        ax.set_ylabel('Actual Category', fontsize=12, fontweight='bold')
        
        # Calculate and display accuracy
        correct_predictions = np.trace(confusion_matrix)
        total_predictions = confusion_matrix.sum()
        accuracy = correct_predictions / total_predictions * 100
        
        ax.text(0.5, -0.15, f'Overall Classification Accuracy: {accuracy:.1f}%', 
               transform=ax.transAxes, ha='center', fontsize=14, fontweight='bold',
               bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/05_confusion_matrix.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Confusion matrix heatmap saved")
    
    def _create_error_distribution_plots(self, save_dir):
        """Create error distribution analysis plots"""
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle('Error Distribution Analysis', fontsize=20, fontweight='bold')
        
        # Get best model
        best_model_name = max(self.results.keys(), key=lambda k: self.results[k]['test_r2'])
        best_result = self.results[best_model_name]
        
        y_test = best_result['y_test']
        y_pred = best_result['predictions']
        errors = np.abs(y_test - y_pred)
        
        # Error histogram
        ax1 = axes[0, 0]
        ax1.hist(errors, bins=30, alpha=0.7, color='skyblue', edgecolor='black')
        ax1.set_xlabel('Absolute Error')
        ax1.set_ylabel('Frequency')
        ax1.set_title('Distribution of Absolute Errors')
        ax1.grid(True, alpha=0.3)
        ax1.axvline(x=errors.mean(), color='red', linestyle='--', linewidth=2, label=f'Mean: {errors.mean():.2f}')
        ax1.legend()
        
        # Error vs predicted values
        ax2 = axes[0, 1]
        ax2.scatter(y_pred, errors, alpha=0.6, s=30, color='coral')
        ax2.set_xlabel('Predicted Values')
        ax2.set_ylabel('Absolute Error')
        ax2.set_title('Error vs Predicted Values')
        ax2.grid(True, alpha=0.3)
        
        # Cumulative accuracy plot
        ax3 = axes[1, 0]
        error_thresholds = np.arange(0, 21, 1)
        accuracies = [(errors <= threshold).mean() * 100 for threshold in error_thresholds]
        ax3.plot(error_thresholds, accuracies, marker='o', linewidth=2, markersize=6, color='green')
        ax3.set_xlabel('Error Threshold (±points)')
        ax3.set_ylabel('Percentage of Predictions (%)')
        ax3.set_title('Cumulative Accuracy Plot')
        ax3.grid(True, alpha=0.3)
        ax3.set_ylim(0, 100)
        
        # Add key accuracy points
        for threshold in [1, 5, 10]:
            accuracy = (errors <= threshold).mean() * 100
            ax3.annotate(f'{accuracy:.1f}%', xy=(threshold, accuracy), 
                        xytext=(threshold+1, accuracy+5), fontweight='bold',
                        arrowprops=dict(arrowstyle='->', color='red'))
        
        # Box plot of errors by score ranges
        ax4 = axes[1, 1]
        score_ranges = ['0-20', '20-40', '40-60', '60-80', '80-100']
        errors_by_range = []
        
        for i in range(5):
            lower = i * 20
            upper = (i + 1) * 20
            mask = (y_test >= lower) & (y_test < upper)
            if mask.any():
                errors_by_range.append(errors[mask])
            else:
                errors_by_range.append([])
        
        box_plot = ax4.boxplot(errors_by_range, labels=score_ranges, patch_artist=True)
        for patch in box_plot['boxes']:
            patch.set_facecolor('lightblue')
        ax4.set_xlabel('Actual Score Range')
        ax4.set_ylabel('Absolute Error')
        ax4.set_title('Error Distribution by Score Range')
        ax4.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/06_error_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Error distribution plots saved")
    
    def _create_statistics_table_image(self, save_dir):
        """Create a statistics summary table as an image"""
        fig, ax = plt.subplots(figsize=(16, 8))
        ax.axis('tight')
        ax.axis('off')
        
        # Prepare data for table
        table_data = []
        headers = ['Model', 'CV R²', 'Test R²', 'RMSE', 'MAE', 'MAPE', 'Max Error', 'Accuracy ±5pts']
        
        for name, result in self.results.items():
            errors = np.abs(result['y_test'] - result['predictions'])
            accuracy_5 = (errors <= 5).mean() * 100
            
            row = [
                name,
                f"{result['cv_mean']:.4f} ±{result['cv_std']:.4f}",
                f"{result['test_r2']:.4f}",
                f"{result['test_rmse']:.2f}",
                f"{result['test_mae']:.2f}",
                f"{result['test_mape']:.1f}%",
                f"{result['test_max_error']:.1f}",
                f"{accuracy_5:.1f}%"
            ]
            table_data.append(row)
        
        # Create table
        table = ax.table(cellText=table_data, colLabels=headers, loc='center', cellLoc='center')
        table.auto_set_font_size(False)
        table.set_fontsize(12)
        table.scale(1.2, 2)
        
        # Style the table
        for i in range(len(headers)):
            table[(0, i)].set_facecolor('#4CAF50')
            table[(0, i)].set_text_props(weight='bold', color='white')
        
        # Color rows alternately
        for i in range(1, len(table_data) + 1):
            for j in range(len(headers)):
                if i % 2 == 0:
                    table[(i, j)].set_facecolor('#f0f0f0')
                else:
                    table[(i, j)].set_facecolor('white')
        
        # Highlight best model
        best_model_idx = max(range(len(table_data)), 
                           key=lambda i: float(table_data[i][2])) + 1
        for j in range(len(headers)):
            table[(best_model_idx, j)].set_facecolor('#FFD700')
            table[(best_model_idx, j)].set_text_props(weight='bold')
        
        plt.title('Model Performance Statistics Summary', fontsize=18, fontweight='bold', pad=20)
        plt.savefig(f'{save_dir}/07_statistics_table.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Statistics table image saved")
    
    def _create_risk_distribution_plot(self, save_dir):
        """Create risk category distribution plots"""
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle('Risk Category Analysis', fontsize=20, fontweight='bold')
        
        # Get best model
        best_model_name = max(self.results.keys(), key=lambda k: self.results[k]['test_r2'])
        best_result = self.results[best_model_name]
        
        y_test = best_result['y_test']
        y_pred = best_result['predictions']
        
        def score_to_category(score):
            if score >= 75: return "Very Safe"
            elif score >= 60: return "Safe"
            elif score >= 45: return "Moderate Risk"
            else: return "High Risk"
        
        y_test_cat = [score_to_category(score) for score in y_test]
        y_pred_cat = [score_to_category(score) for score in y_pred]
        
        categories = ["High Risk", "Moderate Risk", "Safe", "Very Safe"]
        colors = ['#e74c3c', '#f1c40f', '#2ecc71', '#27ae60']
        
        # Actual distribution
        actual_counts = Counter(y_test_cat)
        actual_values = [actual_counts.get(cat, 0) for cat in categories]
        ax1.bar(categories, actual_values, color=colors, alpha=0.8)
        ax1.set_title('Actual Risk Category Distribution')
        ax1.set_ylabel('Count')
        ax1.tick_params(axis='x', rotation=45)
        for i, v in enumerate(actual_values):
            ax1.text(i, v + max(actual_values) * 0.01, str(v), ha='center', fontweight='bold')
        
        # Predicted distribution
        pred_counts = Counter(y_pred_cat)
        pred_values = [pred_counts.get(cat, 0) for cat in categories]
        ax2.bar(categories, pred_values, color=colors, alpha=0.8)
        ax2.set_title('Predicted Risk Category Distribution')
        ax2.set_ylabel('Count')
        ax2.tick_params(axis='x', rotation=45)
        for i, v in enumerate(pred_values):
            ax2.text(i, v + max(pred_values) * 0.01, str(v), ha='center', fontweight='bold')
        
        # Score distribution histogram
        ax3.hist(y_test, bins=20, alpha=0.7, color='skyblue', label='Actual', edgecolor='black')
        ax3.hist(y_pred, bins=20, alpha=0.7, color='orange', label='Predicted', edgecolor='black')
        ax3.set_xlabel('Safety Score')
        ax3.set_ylabel('Frequency')
        ax3.set_title('Safety Score Distribution')
        ax3.legend()
        ax3.grid(True, alpha=0.3)
        
        # Score ranges performance
        score_ranges = ['0-20', '20-40', '40-60', '60-80', '80-100']
        range_performance = []
        
        for i in range(5):
            lower = i * 20
            upper = (i + 1) * 20
            mask = (y_test >= lower) & (y_test < upper)
            if mask.any():
                range_errors = np.abs(y_test[mask] - y_pred[mask])
                range_performance.append(range_errors.mean())
            else:
                range_performance.append(0)
        
        ax4.bar(score_ranges, range_performance, color='lightcoral', alpha=0.8)
        ax4.set_xlabel('Score Range')
        ax4.set_ylabel('Mean Absolute Error')
        ax4.set_title('Model Performance by Score Range')
        ax4.grid(True, alpha=0.3)
        for i, v in enumerate(range_performance):
            if v > 0:
                ax4.text(i, v + max(range_performance) * 0.01, f'{v:.2f}', ha='center', fontweight='bold')
        
        plt.tight_layout()
        plt.savefig(f'{save_dir}/08_risk_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()
        print("   ✓ Risk distribution plots saved")
    
    def predict_safety_score(self, input_data):
        """Predict safety score for new data"""
        if self.model is None:
            print("Model not trained yet!")
            return None
        
        if self.feature_selector is None or self.feature_names is None:
            print("Feature selector or feature names not available!")
            return None
        
        # Prepare input data
        if isinstance(input_data, dict):
            input_df = pd.DataFrame([input_data])
        else:
            input_df = input_data.copy()
        
        # Feature engineering on input
        input_df = self.feature_engineering_single(input_df)
        
        # Select and scale features - handle missing features
        missing_features = []
        for feature in self.feature_names:
            if feature not in input_df.columns:
                missing_features.append(feature)
                input_df[feature] = 0  # Fill with default value
        
        if missing_features:
            print(f"Warning: Missing features filled with 0: {missing_features}")
        
        X_input = input_df[self.feature_names]
        X_input_scaled = self.scaler.transform(X_input)
        X_input_selected = self.feature_selector.transform(X_input_scaled)
        
        # Predict
        prediction = self.model.predict(X_input_selected)
        
        # Constrain predictions to 0-100 range
        prediction = np.clip(prediction, 0, 100)
        
        return prediction
    
    def feature_engineering_single(self, df):
        """Apply feature engineering to single prediction input"""
        # Create the same derived features as in training
        df['total_natural_disasters'] = (df['flood_events'].fillna(0) + df['landslide_events'].fillna(0) + 
                                       df['earthquake_events'].fillna(0) + df['cyclone_events'].fillna(0))
        
        df['infrastructure_index'] = (df['hospitals_per_100k'].fillna(0) + df['police_stations_per_100k'].fillna(0) + 
                                    df['fire_stations_per_100k'].fillna(0)) / 3
        
        df['connectivity_score'] = (df['mobile_network_coverage_percent'].fillna(0) + 
                                  df['internet_connectivity_percent'].fillna(0) + 
                                  df['road_connectivity_index'].fillna(0)) / 3
        
        df['weather_severity'] = df['extreme_weather_days'].fillna(0) * df['rainfall_variability_coefficient'].fillna(0)
        
        df['crime_severity'] = (df['murder_cases'].fillna(0) * 5 + df['rape_cases'].fillna(0) * 4 + 
                              df['kidnapping_cases'].fillna(0) * 3 + df['robbery_cases'].fillna(0) * 2 + 
                              df['theft_cases'].fillna(0)) / np.maximum(df['population'].fillna(1), 1) * 100000
        
        df['population_density'] = df['population'].fillna(0) / 100
        
        return df
    
    def plot_results(self):
        """Plot model performance and feature importance"""
        if not hasattr(self, 'results'):
            print("No results to plot. Train the model first.")
            return
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        
        # Model comparison
        models = list(self.results.keys())
        r2_scores = [self.results[model]['test_r2'] for model in models]
        
        axes[0, 0].bar(models, r2_scores, color=['skyblue', 'lightgreen', 'salmon'])
        axes[0, 0].set_title('Model Performance Comparison (R² Score)')
        axes[0, 0].set_ylabel('R² Score')
        axes[0, 0].tick_params(axis='x', rotation=45)
        
        # Predictions vs Actual for best model
        best_model_name = max(self.results.keys(), key=lambda k: self.results[k]['test_r2'])
        y_pred = self.results[best_model_name]['predictions']
        
        axes[0, 1].scatter(self.y_test, y_pred, alpha=0.7, color='blue')
        axes[0, 1].plot([self.y_test.min(), self.y_test.max()], 
                       [self.y_test.min(), self.y_test.max()], 'r--', lw=2)
        axes[0, 1].set_xlabel('Actual Safety Score')
        axes[0, 1].set_ylabel('Predicted Safety Score')
        axes[0, 1].set_title(f'Predictions vs Actual ({best_model_name})')
        
        # Feature importance
        feature_imp = self.get_feature_importance()
        if feature_imp is not None:
            top_features = feature_imp.head(10)
            axes[1, 0].barh(range(len(top_features)), top_features['importance'])
            axes[1, 0].set_yticks(range(len(top_features)))
            axes[1, 0].set_yticklabels(top_features['feature'])
            axes[1, 0].set_xlabel('Importance')
            axes[1, 0].set_title('Top 10 Feature Importance')
        
        # Residuals plot
        residuals = self.y_test - y_pred
        axes[1, 1].scatter(y_pred, residuals, alpha=0.7, color='green')
        axes[1, 1].axhline(y=0, color='red', linestyle='--')
        axes[1, 1].set_xlabel('Predicted Values')
        axes[1, 1].set_ylabel('Residuals')
        axes[1, 1].set_title('Residuals Plot')
        
        plt.tight_layout()
        plt.show()

# Example usage and demonstration
def main():
    # Initialize the predictor
    predictor = TouristSafetyPredictor()
    
    print("Tourist Safety Score ML Model")
    print("=" * 50)
    print("This model predicts tourist safety scores based on various factors including:")
    print("- Crime statistics")
    print("- Natural disaster frequency")
    print("- Infrastructure quality") 
    print("- Transportation safety")
    print("- Climate factors")
    print()
    
    # Load and prepare data from CSV
    try:
        predictor.load_and_prepare_data(data_path='./data.csv')
        print(f"Data loaded successfully. Features available: {len(predictor.select_features(predictor.df))}")
    except FileNotFoundError:
        print("data.csv not found. Creating sample data for demonstration...")
        # Create sample data based on your provided snippet
        sample_data = {
            'pincode': [790003, 790003],
            'state': ['Arunachal Pradesh', 'Arunachal Pradesh'],
            'locality_name': ['Pasighat New', 'Pasighat New'],
            'area_type': ['Hill Station', 'Hill Station'],
            'year': [2019, 2020],
            'population': [5739, 5796],
            'total_crimes': [7, 4],
            'crime_rate_per_100k': [121.97, 69.01],
            'murder_cases': [0, 0],
            'rape_cases': [2, 1],
            'kidnapping_cases': [1, 0],
            'robbery_cases': [0, 1],
            'theft_cases': [3, 2],
            'burglary_cases': [0, 0],
            'fraud_cases': [1, 0],
            'domestic_violence_cases': [0, 0],
            'crimes_against_women': [2, 1],
            'crimes_against_tourists': [2, 2],
            'insurgency_incidents': [0, 1],
            'flood_events': [2, 8],
            'flood_affected_population': [538, 563],
            'landslide_events': [2, 6],
            'landslide_affected_population': [278, 473],
            'earthquake_events': [3, 5],
            'max_earthquake_magnitude': [5.6, 7.1],
            'lightning_strikes': [9, 5],
            'forest_fires': [2, 0],
            'cyclone_events': [0, 0],
            'road_accidents': [1, 0],
            'road_fatalities': [0, 0],
            'road_injuries': [2, 0],
            'railway_accidents': [0, 0],
            'aviation_incidents': [0, 0],
            'emergency_response_time_minutes': [19.5, 43.0],
            'annual_rainfall_mm': [3060.3, 4597.4],
            'rainfall_variability_coefficient': [0.178, 0.181],
            'max_temperature_celsius': [22.6, 21.8],
            'min_temperature_celsius': [8.0, 3.6],
            'extreme_weather_days': [27, 24],
            'monsoon_onset_deviation_days': [-12, -19],
            'hospitals_per_100k': [45.6, 25.3],
            'police_stations_per_100k': [19.6, 5.1],
            'fire_stations_per_100k': [5.2, 3.2],
            'mobile_network_coverage_percent': [92.8, 62.1],
            'internet_connectivity_percent': [35.1, 70.1],
            'road_connectivity_index': [74.0, 67.2],
            'power_supply_reliability_percent': [68.2, 86.6],
            'crime_score': [84.75, 91.37],
            'natural_hazard_score': [46, 0],
            'transport_safety_score': [100.0, 95.0],
            'infrastructure_score': [55.0, 40.26],
            'composite_safety_score': [73.96, 59.76],
            'risk_category': ['Safe', 'Moderate Risk']
        }
        
        # Create DataFrame
        df = pd.DataFrame(sample_data)
        predictor.load_and_prepare_data(df=df)
        print("Note: Using sample data for demonstration purposes.")
        print("For production use, you would need a much larger dataset.")
    
    # Train the model
    print("\nTraining the model...")
    results = predictor.train_model()
    
    # Print model comparison summary
    predictor.print_model_comparison_summary()
    
    # Generate comprehensive performance report
    predictor.generate_performance_report()
    
    # Display feature importance
    print("\n🔑 FEATURE IMPORTANCE ANALYSIS:")
    print("-" * 50)
    feature_imp = predictor.get_feature_importance()
    if feature_imp is not None:
        print("Top 15 Most Important Features:")
        for i, (idx, row) in enumerate(feature_imp.head(15).iterrows(), 1):
            print(f"{i:2d}. {row['feature']:<35} {row['importance']:>8.4f}")
    else:
        print("Feature importance not available for this model type.")
    
    # Generate comprehensive visualizations
    print("\n📊 Generating comprehensive visualizations...")
    predictor.create_comprehensive_visualizations()
    
    # Plot results if matplotlib is available
    try:
        predictor.plot_results()
    except Exception as e:
        print(f"Could not generate additional plots: {e}")
    
    # Test prediction with sample data
    print("\nTesting prediction with sample data...")
    sample_input = {
        'pincode': 790003,
        'state': 'Arunachal Pradesh',
        'locality_name': 'Pasighat New',
        'area_type': 'Hill Station',
        'year': 2024,
        'population': 6000,
        'total_crimes': 3,
        'crime_rate_per_100k': 50.0,
        'murder_cases': 0,
        'rape_cases': 0,
        'kidnapping_cases': 0,
        'robbery_cases': 1,
        'theft_cases': 2,
        'burglary_cases': 0,
        'fraud_cases': 0,
        'domestic_violence_cases': 0,
        'crimes_against_women': 0,
        'crimes_against_tourists': 1,
        'insurgency_incidents': 0,
        'flood_events': 2,
        'flood_affected_population': 300,
        'landslide_events': 1,
        'landslide_affected_population': 100,
        'earthquake_events': 2,
        'max_earthquake_magnitude': 5.0,
        'lightning_strikes': 5,
        'forest_fires': 1,
        'cyclone_events': 0,
        'road_accidents': 2,
        'road_fatalities': 0,
        'road_injuries': 3,
        'railway_accidents': 0,
        'aviation_incidents': 0,
        'emergency_response_time_minutes': 25.0,
        'annual_rainfall_mm': 3000.0,
        'rainfall_variability_coefficient': 0.2,
        'max_temperature_celsius': 25.0,
        'min_temperature_celsius': 10.0,
        'extreme_weather_days': 20,
        'monsoon_onset_deviation_days': 5,
        'hospitals_per_100k': 30.0,
        'police_stations_per_100k': 15.0,
        'fire_stations_per_100k': 5.0,
        'mobile_network_coverage_percent': 80.0,
        'internet_connectivity_percent': 60.0,
        'road_connectivity_index': 70.0,
        'power_supply_reliability_percent': 75.0
    }
    
    try:
        prediction = predictor.predict_safety_score(sample_input)
        if prediction is not None:
            print(f"Predicted safety score: {prediction[0]:.2f}")
        else:
            print("Could not generate prediction - model may not be trained properly")
    except Exception as e:
        print(f"Error in prediction: {e}")
    
    return predictor

if __name__ == "__main__":
    predictor = main()