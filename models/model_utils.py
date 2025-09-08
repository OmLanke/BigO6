import pickle
import os
from train import TouristSafetyPredictor

def save_model(predictor, model_path='tourist_safety_model.pkl'):
    """Save the trained model to disk"""
    try:
        with open(model_path, 'wb') as f:
            pickle.dump(predictor, f)
        print(f"Model saved successfully to {model_path}")
    except Exception as e:
        print(f"Error saving model: {e}")

def load_model(model_path='tourist_safety_model.pkl'):
    """Load a trained model from disk"""
    try:
        if not os.path.exists(model_path):
            print(f"Model file {model_path} not found!")
            return None
        
        with open(model_path, 'rb') as f:
            predictor = pickle.load(f)
        print(f"Model loaded successfully from {model_path}")
        return predictor
    except Exception as e:
        print(f"Error loading model: {e}")
        return None

def train_and_save_model(data_path='./data.csv', model_path='tourist_safety_model.pkl'):
    """Train a new model and save it"""
    print("Training new model...")
    predictor = TouristSafetyPredictor()
    
    # Load and train
    predictor.load_and_prepare_data(data_path=data_path)
    results = predictor.train_model()
    
    # Save the model
    save_model(predictor, model_path)
    
    return predictor

def predict_with_saved_model(input_data, model_path='tourist_safety_model.pkl'):
    """Make predictions using a saved model"""
    predictor = load_model(model_path)
    if predictor is None:
        return None
    
    return predictor.predict_safety_score(input_data)

if __name__ == "__main__":
    # Example usage
    print("Tourist Safety Model Utilities")
    print("=" * 40)
    
    # Train and save a new model
    predictor = train_and_save_model()
    
    # Test prediction
    sample_input = {
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
    
    prediction = predict_with_saved_model(sample_input)
    if prediction is not None:
        print(f"\nPredicted safety score: {prediction[0]:.2f}")
