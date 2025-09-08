# Tourist Safety Score Prediction Model

This machine learning model predicts tourist safety scores based on various factors including crime statistics, natural disasters, infrastructure quality, transportation safety, and climate factors.

## Features

The model uses 42+ features including:
- **Crime statistics**: Murder, rape, kidnapping, robbery, theft, fraud cases
- **Natural disasters**: Floods, landslides, earthquakes, cyclones, forest fires
- **Transportation safety**: Road accidents, fatalities, emergency response times
- **Infrastructure**: Hospitals, police stations, fire stations per 100k population
- **Climate factors**: Rainfall, temperature extremes, extreme weather days
- **Connectivity**: Mobile network, internet connectivity, road connectivity

## Model Performance

The current model achieves:
- **Best Model**: Linear Regression
- **Cross-validation R² Score**: 0.9723 ± 0.0165
- **Test R² Score**: 0.9728
- **Test MAE**: 0.7606

## Files

- `train.py`: Main training script and model implementation
- `model_utils.py`: Utilities for saving/loading trained models
- `api.py`: Flask API for serving predictions (requires Flask)
- `data.csv`: Training dataset (5000+ records)

## Usage

### 1. Train the Model

```python
python train.py
```

This will:
- Load the dataset
- Train multiple models (Random Forest, Gradient Boosting, Linear Regression)
- Select the best performing model
- Display feature importance
- Test predictions

### 2. Save/Load Models

```python
from model_utils import train_and_save_model, load_model, predict_with_saved_model

# Train and save
predictor = train_and_save_model()

# Load existing model
predictor = load_model('tourist_safety_model.pkl')

# Make prediction with saved model
prediction = predict_with_saved_model(input_data)
```

### 3. Make Predictions

```python
from train import TouristSafetyPredictor

predictor = TouristSafetyPredictor()
predictor.load_and_prepare_data(data_path='./data.csv')
predictor.train_model()

# Sample input
sample_input = {
    'year': 2024,
    'population': 50000,
    'total_crimes': 25,
    'crime_rate_per_100k': 50.0,
    'murder_cases': 1,
    'rape_cases': 2,
    # ... other features
}

prediction = predictor.predict_safety_score(sample_input)
print(f"Predicted safety score: {prediction[0]:.2f}")
```

### 4. API Server (Optional)

```bash
# Install Flask first
pip install flask

# Run API server
python api.py
```

API Endpoints:
- `GET /health`: Health check
- `POST /predict`: Single prediction
- `POST /batch_predict`: Batch predictions
- `GET /feature_importance`: Get feature importance
- `GET /example`: Get example input format

## Safety Score Interpretation

- **80-100**: Very Safe
- **65-79**: Safe
- **50-64**: Moderate Risk
- **35-49**: High Risk
- **0-34**: Very High Risk

## Requirements

```bash
pip install pandas numpy scikit-learn matplotlib seaborn
```

For API:
```bash
pip install flask
```

## Model Features Importance

Top features that influence safety scores:
1. Crime rate per 100k population
2. Flood events
3. Landslide events  
4. Earthquake events
5. Forest fires
6. Infrastructure index
7. Connectivity score
8. Power supply reliability
9. Internet connectivity
10. Crime severity

## Data Requirements

Input data should include as many of the following features as possible:

**Required Features:**
- `year`, `population`, `total_crimes`, `crime_rate_per_100k`
- Basic crime statistics (murder, rape, theft cases, etc.)
- Natural disaster events (floods, landslides, earthquakes)
- Infrastructure metrics (hospitals, police stations per 100k)

**Optional Features:**
- Detailed climate data
- Transportation safety metrics
- Connectivity percentages

Missing features will be filled with default values (0) but may affect prediction accuracy.

## Example Dataset Row

```csv
pincode,state,locality_name,area_type,year,population,total_crimes,crime_rate_per_100k,...
790003,Arunachal Pradesh,Pasighat New,Hill Station,2019,5739,7,121.97,...
```

The dataset contains 5000+ records across different regions and years, providing comprehensive training data for accurate predictions.
