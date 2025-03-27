# python -m venv venv
# source venv/Scripts/activate
# pip install -r requirements.txt

import pandas as pd
import os
import joblib
import matplotlib.pyplot as plt

# 🔹 저장된 K-Means 모델 & Scaler 불러오기
kmeans_loaded = joblib.load(os.path.join("kmeans_model.pkl"))
scaler_loaded = joblib.load(os.path.join("scaler.pkl"))

# 군집 -> 실제 유형
cluster_to_type = {
    0: "비상금형",
    1: "평균형",
    2: "cu점장형",
    3: "교통형",
    4: "미식가형",
    5: "절약형",
    6: "쇼핑중독자",
    7: "커피중독자",
    8: "여가형",
}

# 🔹 새로운 사용자 소비 패턴 입력
user_input = pd.DataFrame([{
    "고정지출": 0.01,
    "식비/외식": 0.19,
    "교통/자동차": 0.22,
    "편의점/마트": 0.14,
    "금융": 0.67,
    "여가비": 0.17,
    "커피/디저트": 0.03,
    "쇼핑": 0.21,
    "비상금": 0.05
}])

# 🔹 사용자 데이터 표준화
user_scaled = scaler_loaded.transform(user_input)

# 🔹 사용자 군집 예측
user_cluster = kmeans_loaded.predict(user_scaled)[0]
print(f"\n🔍 사용자가 속한 군집: {user_cluster}")
print(f"✅ 사용자 유형: {cluster_to_type[user_cluster]}")

# 🔹 군집화된 데이터 불러오기
df = pd.read_csv(os.path.join("군집화된_소비패턴.csv"), encoding="cp949")

# 🔹 같은 군집에 속한 데이터 추출
similar_cluster_data = df[df['군집'] == user_cluster]
print("\n📊 유사한 군집의 평균 예산 비율:")
print(similar_cluster_data.drop(columns=["월급", "군집"]).mean().round(2))