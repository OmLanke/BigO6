"""
Simple API for Tourist Safety Score Prediction
This script provides a simple Flask API to serve the tourist safety prediction model.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from model_utils import load_model, train_and_save_model
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes and origins

# Global variable to store the loaded model
model = None

def load_or_train_model():
    """Load existing model or train a new one if not found"""
    global model
    
    model_path = 'tourist_safety_model.pkl'
    
    if os.path.exists(model_path):
        print("Loading existing model...")
        model = load_model(model_path)
    else:
        print("No existing model found. Training new model...")
        model = train_and_save_model(model_path=model_path)
    
    if model is None:
        raise Exception("Failed to load or train model!")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Predict safety score for given input"""
    try:
        if model is None:
            return jsonify({
                'error': 'Model not loaded'
            }), 500
        
        # Get input data from request
        input_data = request.get_json()
        
        if not input_data:
            return jsonify({
                'error': 'No input data provided'
            }), 400
        
        # Make prediction
        prediction = model.predict_safety_score(input_data)
        
        if prediction is None:
            return jsonify({
                'error': 'Prediction failed'
            }), 500
        
        # Ensure prediction is within valid range
        score = max(0, min(100, float(prediction[0])))
        
        return jsonify({
            'predicted_safety_score': score,
            'interpretation': get_risk_interpretation(score)
        })
    
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 500

@app.route('/batch_predict', methods=['POST'])
def batch_predict():
    """Predict safety scores for multiple inputs"""
    try:
        if model is None:
            return jsonify({
                'error': 'Model not loaded'
            }), 500
        
        # Get input data from request
        input_data = request.get_json()
        
        if not input_data or 'inputs' not in input_data:
            return jsonify({
                'error': 'No input data provided. Expected format: {"inputs": [...]}'
            }), 400
        
        inputs = input_data['inputs']
        predictions = []
        
        for i, single_input in enumerate(inputs):
            try:
                prediction = model.predict_safety_score(single_input)
                if prediction is not None:
                    score = max(0, min(100, float(prediction[0])))
                    predictions.append({
                        'index': i,
                        'predicted_safety_score': score,
                        'interpretation': get_risk_interpretation(score)
                    })
                else:
                    predictions.append({
                        'index': i,
                        'error': 'Prediction failed'
                    })
            except Exception as e:
                predictions.append({
                    'index': i,
                    'error': str(e)
                })
        
        return jsonify({
            'predictions': predictions
        })
    
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 500

@app.route('/feature_importance', methods=['GET'])
def get_feature_importance():
    """Get feature importance from the model"""
    try:
        if model is None:
            return jsonify({
                'error': 'Model not loaded'
            }), 500
        
        feature_imp = model.get_feature_importance()
        
        if feature_imp is None:
            return jsonify({
                'error': 'Feature importance not available'
            }), 500
        
        # Convert to dictionary format
        importance_data = {
            'features': feature_imp['feature'].tolist(),
            'importance_values': feature_imp['importance'].tolist()
        }
        
        return jsonify(importance_data)
    
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 500

def get_risk_interpretation(score):
    """Interpret the safety score"""
    # Ensure score is within 0-100 range
    score = max(0, min(100, score))
    
    if score >= 80:
        return "Very Safe"
    elif score >= 65:
        return "Safe"
    elif score >= 50:
        return "Moderate Risk"
    elif score >= 35:
        return "High Risk"
    else:
        return "Very High Risk"

@app.route('/example', methods=['GET'])
def get_example():
    """Get an example input format"""
    example_input = {
        'year': 2024,
        'population': 50000,
        'total_crimes': 25,
        'crime_rate_per_100k': 50.0,
        'murder_cases': 1,
        'rape_cases': 2,
        'kidnapping_cases': 1,
        'robbery_cases': 3,
        'theft_cases': 15,
        'burglary_cases': 2,
        'fraud_cases': 1,
        'domestic_violence_cases': 3,
        'crimes_against_women': 5,
        'crimes_against_tourists': 2,
        'insurgency_incidents': 0,
        'flood_events': 3,
        'flood_affected_population': 1000,
        'landslide_events': 1,
        'landslide_affected_population': 200,
        'earthquake_events': 2,
        'max_earthquake_magnitude': 5.5,
        'lightning_strikes': 10,
        'forest_fires': 2,
        'cyclone_events': 1,
        'road_accidents': 15,
        'road_fatalities': 2,
        'road_injuries': 25,
        'railway_accidents': 0,
        'aviation_incidents': 0,
        'emergency_response_time_minutes': 20.0,
        'annual_rainfall_mm': 2500.0,
        'rainfall_variability_coefficient': 0.25,
        'max_temperature_celsius': 30.0,
        'min_temperature_celsius': 15.0,
        'extreme_weather_days': 25,
        'monsoon_onset_deviation_days': 10,
        'hospitals_per_100k': 25.0,
        'police_stations_per_100k': 10.0,
        'fire_stations_per_100k': 5.0,
        'mobile_network_coverage_percent': 85.0,
        'internet_connectivity_percent': 70.0,
        'road_connectivity_index': 75.0,
        'power_supply_reliability_percent': 80.0
    }
    
    return jsonify({
        'example_input': example_input,
        'usage': {
            'predict_single': 'POST /predict with the above JSON',
            'predict_batch': 'POST /batch_predict with {"inputs": [input1, input2, ...]}'
        }
    })

if __name__ == '__main__':
    # Load or train model on startup
    try:
        load_or_train_model()
        print("Model loaded successfully!")
        
        # Start the API server
        app.run(
            host='0.0.0.0',
            port=5000,
            debug=True
        )
    except Exception as e:
        print(f"Failed to start API: {e}")
