import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.feature_selection import SelectKBest, f_regression
import joblib

# 假设数据加载函数
def load_data():
    # 实际数据加载
    X = pd.DataFrame(np.random.rand(100, 10))  # 假设有10个特征
    y = pd.DataFrame({
        'arousal': np.random.rand(100),
        'valence': np.random.rand(100)
    })
    return X, y

# 特征工程
def feature_engineering(X, y_arousal, y_valence):
    # 数据标准化
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    joblib.dump(scaler, 'scaler.joblib')  # 保存标准化器
    
    # 特征选择 for arousal
    selector_arousal = SelectKBest(f_regression, k=5)
    X_selected_arousal = selector_arousal.fit_transform(X_scaled, y_arousal)
    joblib.dump(selector_arousal, 'selector_arousal.joblib')  # 保存特征选择器

    # 特征选择 for valence
    selector_valence = SelectKBest(f_regression, k=5)
    X_selected_valence = selector_valence.fit_transform(X_scaled, y_valence)
    joblib.dump(selector_valence, 'selector_valence.joblib')  # 保存特征选择器
    
    return X_selected_arousal, X_selected_valence

# 模型训练和优化
def train_model(X_train, y_train):
    model = RandomForestRegressor()
    param_distributions = {
        'n_estimators': [100, 200, 300],
        'max_depth': [None, 10, 20, 30],
        'min_samples_split': [2, 4, 6],
        'min_samples_leaf': [1, 2, 3]
    }
    random_search = RandomizedSearchCV(
        estimator=model,
        param_distributions=param_distributions,
        n_iter=10,
        cv=3,
        verbose=2,
        random_state=42,
        scoring='neg_mean_squared_error'
    )
    random_search.fit(X_train, y_train)
    joblib.dump(random_search.best_estimator_, 'random_forest_model.joblib')
    return random_search.best_estimator_

# 性能评估
def evaluate_model(model, X_test, y_test):
    predictions = model.predict(X_test)
    mse = mean_squared_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)
    return mse, r2

def main():
    X, y = load_data()
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Feature engineering
    X_train_arousal, X_train_valence = feature_engineering(X_train, y_train['arousal'], y_train['valence'])
    X_test_arousal, X_test_valence = feature_engineering(X_test, y_test['arousal'], y_test['valence'])

    # Training model for Arousal
    model_arousal = train_model(X_train_arousal, y_train['arousal'])
    mse_arousal, r2_arousal = evaluate_model(model_arousal, X_test_arousal, y_test['arousal'])
    print(f"Arousal - Test MSE: {mse_arousal}, Test R²: {r2_arousal}")

    # Training model for Valence (optional)
    model_valence = train_model(X_train_valence, y_train['valence'])
    mse_valence, r2_valence = evaluate_model(model_valence, X_test_valence, y_test['valence'])
    print(f"Valence - Test MSE: {mse_valence}, Test R²: {r2_valence}")

if __name__ == "__main__":
    main()
