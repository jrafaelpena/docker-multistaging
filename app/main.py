import joblib
from pathlib import Path
from sklearn.datasets import load_iris

iris = load_iris()
X = iris.data
y = iris.target

model = joblib.load('lgbm_model.pkl')

y_pred = model.predict_proba(X[0:6])

print(y_pred)