# python -m venv venv
# source venv/Scripts/activate
# pip install numpy pandas scikit-learn

import numpy as np
import pandas as pd
from sklearn.cluster import KMeans

# 샘플 데이터 (식비, 교통비, 고정지출, 생활비, 카페/간식)
data = np.array([
    [0.3, 0.1, 0.5, 0.1, 0.03],  # 미식가
    [0.2, 0.2, 0.4, 0.1, 0.05],  # 균형형
    [0.1, 0.3, 0.3, 0.2, 0.1],   # 여행자
    [0.05, 0.2, 0.6, 0.1, 0.05], # 절약형
])

# K-Means 모델 생성
kmeans = KMeans(n_clusters=3, random_state=42)
kmeans.fit(data)

# 클러스터 중심값 출력 (각 유형별 평균 소비 패턴)
cluster_centers = pd.DataFrame(kmeans.cluster_centers_, columns=["식비", "교통비", "고정지출", "생활비", "카페/간식"])
print("각 유형의 평균 소비 패턴:")
print(cluster_centers)

# 새로운 사용자 입력
new_user = np.array([[0.25, 0.15, 0.4, 0.15, 0.05]])
user_cluster = kmeans.predict(new_user)

print(f"이 사용자는 {user_cluster[0]}번 유형에 속합니다.")
