# python -m venv venv
# source venv/Scripts/activate
# pip install scikit-learn fastapi uvicorn

# uvicorn gbhAi:ai --host 0.0.0.0 --port 8000 --reload

import pickle
import pandas as pd
import os
import joblib

from typing import List
from pydantic import BaseModel
from fastapi import FastAPI


class TradeNamesInput(BaseModel):
    tradeNames: List[str]

class BudgetType(BaseModel):
    salary: int
    fixed_expense: float
    food_expense: float
    transportation_expense: float
    market_expense: float
    financial_expense: float
    leisure_expense: float
    coffee_expense: float
    shopping_expense: float
    emergency_expense: float



ai = FastAPI()

@ai.post("/category")
async def classify_category(data: TradeNamesInput):
    # 저장된 모델, 벡터화기, 레이블 인코더 불러오기
    with open('model.pkl', 'rb') as model_file:
        clf = pickle.load(model_file)

    with open('vectorizer.pkl', 'rb') as vectorizer_file:
        vectorizer = pickle.load(vectorizer_file)

    with open('label_encoder.pkl', 'rb') as le_file:
        le = pickle.load(le_file)

    # 새로운 입력값
    new_names = data.tradeNames

    # 입력값 벡터화
    X_new = vectorizer.transform(new_names)

    # 예측 수행
    y_pred = clf.predict(X_new)

    # 예측된 레이블을 실제 업종명으로 변환
    y_pred_labels = le.inverse_transform(y_pred)

    # 결과 출력
    result = {}
    for name, category in zip(new_names, y_pred_labels):
        result[name] = category

    return result
        
@ai.post("/type")
async def budget_type(data: BudgetType):
    # 🔹 저장된 K-Means 모델 & Scaler 불러오기
    kmeans_loaded = joblib.load(os.path.join("kmeans_model.pkl"))
    scaler_loaded = joblib.load(os.path.join("scaler.pkl"))

    # 군집 -> 실제 유형
    cluster_to_type = {
        0: "비상금",
        1: "평균",
        2: "편의점/마트",
        3: "커피/디저트",
        # 3: "교통비/자동차",
        4: "식비/외식",
        # 4: "식비/외식",
        5: "쇼핑",
        # 5: "금융",
        6: "교통/자동차",
        # 6: "쇼핑",
        7: "금융",
        # 7: "쇼핑",
        # 7: "커피/디저트",
        8: "여가비",
    }
    
    # 🔹 새로운 사용자 소비 패턴 입력
    user_input = pd.DataFrame([{
        "고정지출": data.fixed_expense,
        "식비/외식": data.food_expense,
        "교통/자동차": data.transportation_expense,
        "편의점/마트": data.market_expense,
        "금융": data.financial_expense,
        "여가비": data.leisure_expense,
        "커피/디저트": data.coffee_expense,
        "쇼핑": data.shopping_expense,
        "비상금": data.emergency_expense
    }])

    # 🔹 사용자 데이터 표준화
    user_scaled = scaler_loaded.transform(user_input)

    # 🔹 사용자 군집 예측
    user_cluster = kmeans_loaded.predict(user_scaled)[0]
    print(f"\n🔍 사용자가 속한 군집: {user_cluster}") # (0~8)
    print(f"✅ 사용자 유형: {cluster_to_type[user_cluster]}")

    # 🔹 군집화된 데이터 불러오기
    df = pd.read_csv(os.path.join("군집화된_소비패턴.csv"), encoding="cp949")

    # 🔹 같은 군집에 속한 데이터 추출
    similar_cluster_data = df[df['군집'] == user_cluster]
    # print("\n📊 유사한 군집의 평균 예산 비율:")
    # print(similar_cluster_data.drop(columns=["월급", "군집"]).mean().round(2))

    # 평균 계산 후 반올림
    mean_values = similar_cluster_data.drop(columns=["월급", "군집"]).mean().round(2)

    # 프론트 사용 아래 1,2
    # 컬럼 이름과 값을 출력
    # 1. 내 유형 데이터 my_data
    my_data = {}
    for column, value in mean_values.items():
        my_data[column] = value
    print(f"\n📊 유사한 군집의 평균 예산 데이터: {my_data}")

    # 2. 다른 유형 데이터 all_data
    all_data = {}
    for cluster in range(9):
        if cluster == user_cluster:
            continue
        other_cluster_data =  df[df['군집'] == cluster]
        mean_values_other = other_cluster_data.drop(columns=["월급", "군집"]).mean().round(2)
        # print(f"\n📊 {cluster_to_type[cluster]} 평균 예산 데이터: {mean_values_other}")    
        data = {}
        for column, value in mean_values_other.items():
            data[column] = value
        all_data[cluster_to_type[cluster]] = data

    # print(f"\n📊 전체 유형 평균 예산 데이터: {all_data}")

    data = {
        "my_data": {cluster_to_type[user_cluster] : my_data},
        "all_data": all_data
    }

    # print(f"\n📊 응답 데이터: {data}")
    return data


# # 저장된 모델, 벡터화기, 레이블 인코더 불러오기
# with open('model.pkl', 'rb') as model_file:
#     clf = pickle.load(model_file)

# with open('vectorizer.pkl', 'rb') as vectorizer_file:
#     vectorizer = pickle.load(vectorizer_file)

# with open('label_encoder.pkl', 'rb') as le_file:
#     le = pickle.load(le_file)

# # 새로운 입력값
# new_names = [
#     "쿠팡", "무신사",
#   "한옥집", "명가설렁탕",
#   "왕푸차이나", "차이나타운",
#   "육풍", "한우명가",
#   "커피하우스", "더 브루",
#   "스위트하우스", "베이커리101",
#   "31 아이스크림", "스노우스윗",
#   "떡마을", "한옥떡집"
# ]



# # 입력값 벡터화
# X_new = vectorizer.transform(new_names)

# # 예측 수행
# y_pred = clf.predict(X_new)

# # 예측된 레이블을 실제 업종명으로 변환
# y_pred_labels = le.inverse_transform(y_pred)

# # 결과 출력
# for name, category in zip(new_names, y_pred_labels):
#     # 예외 처리 부탁해용 지은씨
#     if name == "쿠팡":
#         category = "쇼핑"
#     print(f"상호명: {name} -> 예측 업종: {category}")
