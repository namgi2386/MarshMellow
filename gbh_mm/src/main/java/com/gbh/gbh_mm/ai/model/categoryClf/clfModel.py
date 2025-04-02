import json
import pickle
import sys
from dotenv import load_dotenv
import os

# 모델 및 전처리기 불러오기
load_dotenv(dotenv_path="src/main/resources/.env")
model_path = os.getenv("MODEL_PATH")
try:
    with open(f'{model_path}/categoryClf/model.pkl', 'rb') as model_file:
        clf = pickle.load(model_file)

    with open(f'{model_path}/categoryClf/vectorizer.pkl', 'rb') as vectorizer_file:
        vectorizer = pickle.load(vectorizer_file)

    with open(f'{model_path}/categoryClf/label_encoder.pkl', 'rb') as le_file:
        le = pickle.load(le_file)
except Exception as e:
    print(json.dumps({"status": "error", "message": f"Failed to load model: {str(e)}"}))
    sys.exit(1)

def predict_category(tradeNames):
    try:
        # ✅ 입력값 벡터화
        X_new = vectorizer.transform(tradeNames)

        # ✅ 예측 수행
        y_pred = clf.predict(X_new)
        
        # ✅ 예측된 레이블을 실제 업종명으로 변환
        y_pred_labels = le.inverse_transform(y_pred)

        # ✅ 결과 저장
        results = {}
        for tradeName, category in zip(tradeNames, y_pred_labels):
            if tradeName == "쿠팡":
                category = "쇼핑"
            results[tradeName] = str(category)

        return {"predictions": results}

    except Exception as e:
        return {"status": "error", "message": str(e)}

def main():
    try:
        # ✅ JSON 데이터 읽기
        input_json = sys.stdin.read()
        if not input_json:
            raise ValueError("No input data received")

        input_data = json.loads(input_json)

        # ✅ "names" 키 확인
        if "tradeNames" not in input_data or not isinstance(input_data["tradeNames"], list):
            raise ValueError("Invalid input format")

        tradeNames = input_data["tradeNames"]

        # ✅ 예측 실행
        response = predict_category(tradeNames)

        # ✅ JSON 출력
        print(json.dumps(response, ensure_ascii=False))

    except Exception as e:
        error_response = {"status": "error", "message": str(e)}
        print(json.dumps(error_response, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()
