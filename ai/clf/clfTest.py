# python -m venv venv
# source venv/Scripts/activate
# pip install scikit-learn
# python clfTest.py

import pickle

# 저장된 모델, 벡터화기, 레이블 인코더 불러오기
with open('model.pkl', 'rb') as model_file:
    clf = pickle.load(model_file)

with open('vectorizer.pkl', 'rb') as vectorizer_file:
    vectorizer = pickle.load(vectorizer_file)

with open('label_encoder.pkl', 'rb') as le_file:
    le = pickle.load(le_file)

# 새로운 입력값
new_names = [
    "쿠팡", "무신사",
  "한옥집", "명가설렁탕",
  "왕푸차이나", "차이나타운",
  "육풍", "한우명가",
  "커피하우스", "더 브루",
  "스위트하우스", "베이커리101",
  "31 아이스크림", "스노우스윗",
  "떡마을", "한옥떡집"
]

# 입력값 벡터화
X_new = vectorizer.transform(new_names)

# 예측 수행
y_pred = clf.predict(X_new)

# 예측된 레이블을 실제 업종명으로 변환
y_pred_labels = le.inverse_transform(y_pred)

# 결과 출력
for name, category in zip(new_names, y_pred_labels):
    # 예외 처리 부탁해용 지은씨
    if name == "쿠팡":
        category = "쇼핑"
    print(f"상호명: {name} -> 예측 업종: {category}")
