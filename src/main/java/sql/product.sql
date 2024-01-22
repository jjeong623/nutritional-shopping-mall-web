--상품 테이블
CREATE TABLE PRODUCT(
	-- 상품번호(기본키)
	P_ID INT PRIMARY KEY,
	-- 제품설명
	-- 01_18_NOT NULL 추가
	P_DETAIL VARCHAR2(500) NOT NULL,
	-- 상품이름(20자 제한)
	P_NAME VARCHAR2(60) NOT NULL,
	-- 상품 원가
	COST_PRICE INT NOT NULL,
	-- 상품 정가
	REGULAR_PRICE INT NOT NULL,
	-- 상품 판매가
	SELLING_PRICE INT NOT NULL,
	-- 상품재고
	P_QTY INT NOT NULL,
	-- 상품성분(상품 성분 100자 제한)
	-- 01_18_자료크기 300 -> 600
	INGREDIENT VARCHAR2(600) NOT NULL,
	-- 상품용법(25자 제한) //  1일 2회, 1회 2정 섭취(공백포함 21byte)
	-- 01_18_NOT NULL 추가
	USAGE VARCHAR2(75) DEFAULT '1일 2회, 1회 2정 섭취' NOT NULL,
	-- 유통기한
	-- 01_18_NOT NULL 추가
	EXP VARCHAR2(75) DEFAULT '제조일로부터 24개월' NOT NULL,
	-- 카테고리
	CATEGORY VARCHAR2(75) NOT NULL,
	-- 등록일
	REG_TIME TIMESTAMP NOT NULL,
	-- 판매상태
	-- NOT NULL 작성_01_13
	SELLING_STATE VARCHAR2(15) NOT NULL,
	-- 상품이미지 경로
	-- 추가작성_01_13
	IMAGEPATH VARCHAR2(255)
);

------------------------------------------------------상품 샘플 코드 --------------------------------------------------------------------------
--제품추가
INSERT INTO PRODUCT (P_ID, P_NAME, P_DETAIL, COST_PRICE, REGULAR_PRICE, SELLING_PRICE, P_QTY, INGREDIENT, CATEGORY, REG_TIME, SELLING_STATE, IMAGEPATH)
VALUES (
  NVL((SELECT MAX(P_ID) FROM PRODUCT), 0) + 1,
  '진라면',
  '상품설명',
  10000,  -- 원가
  15000,  -- 정가
  750,  -- 판매가
  50,     -- 재고
  '상품 성분',
  '라면',
  SYSTIMESTAMP, -- 현재 시간
  '판매중',       
  '이미지 경로'
);
--최대가격 찾기
SELECT MAX(SELLING_PRICE) AS PRICE FROM PRODUCT;

--제품출력(전체)
--GROUP BY를 사용할 때, SELECT 문에 나열되지 않은 열들은 집계 함수로 그룹화된 결과를 계산하는 데 사용할 수 없다
--LEFT JOIN을 사용해서 TOTAL_B_QTY가 없는 행도 출력한다
--COALESCE(SUM(B.B_QTY), 0)을 사용해 SUM(B.B_QTY)의 결과가 NULL이면 0을 반환한다
--인자를 2개 이상 사용 가능하고 앞의 인자가 NULL이면 뒤의 인자를 반환을 반복하며 첫번째 NULL이 아닌값을 반환
--NVL(SUM(B.B_QTY), 0) 상황에 맞는 코드 사용
SELECT P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, 
P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, 
P.SELLING_STATE, P.IMAGEPATH, NVL(SUM(B.B_QTY), 0) AS TOTAL_B_QTY
FROM PRODUCT P
LEFT JOIN BUYINFO B ON P.P_ID = B.P_ID
GROUP BY P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, 
P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, 
P.SELLING_STATE, P.IMAGEPATH
ORDER BY TOTAL_B_QTY DESC, REG_TIME DESC;

--필터 테스트 1
SELECT P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, 
P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, 
P.SELLING_STATE, P.IMAGEPATH, NVL(SUM(B.B_QTY), 0) AS TOTAL_B_QTY
FROM PRODUCT P
LEFT JOIN BUYINFO B ON P.P_ID = B.P_ID
WHERE
    P.SELLING_STATE = '판매중' 
    AND (P.P_NAME LIKE '%%' OR P.P_NAME IS NULL)
    AND (P.CATEGORY LIKE '%%' OR P.CATEGORY IS NULL)
    AND (P.SELLING_PRICE <= 13000 OR P.SELLING_PRICE IS NULL)
GROUP BY P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, 
P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, 
P.SELLING_STATE, P.IMAGEPATH
ORDER BY TOTAL_B_QTY DESC, REG_TIME DESC;

--제품출력(페이지)
SELECT P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, P.SELLING_STATE, P.IMAGEPATH, NVL(SUM(B.B_QTY), 0) AS TOTAL_B_QTY
FROM (
    SELECT P_ID, P_NAME, P_DETAIL, COST_PRICE, REGULAR_PRICE, SELLING_PRICE, P_QTY, INGREDIENT, CATEGORY, REG_TIME, SELLING_STATE, IMAGEPATH, ROWNUM AS RN
    FROM PRODUCT
    WHERE SELLING_STATE = '판매중'
) P
LEFT JOIN BUYINFO B ON P.P_ID = B.P_ID
WHERE RN BETWEEN 1 AND 8
GROUP BY P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, 
P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, 
P.SELLING_STATE, P.IMAGEPATH
ORDER BY TOTAL_B_QTY DESC, REG_TIME DESC;

--제품상세(최신 리뷰가 위로)
SELECT P.P_ID, P.P_NAME, P.P_DETAIL, P.COST_PRICE, P.REGULAR_PRICE, 
P.SELLING_PRICE, P.P_QTY, P.INGREDIENT, P.CATEGORY, P.REG_TIME, 
P.SELLING_STATE, P.IMAGEPATH, P.USAGE, P.EXP, R.R_ID, R.M_ID, R.B_ID, R.SCORE, R.CONTENTS, R.CREATE_TIME
FROM PRODUCT P
JOIN BUYINFO B ON P.P_ID = B.P_ID
JOIN REVIEW R ON B.B_ID = R.B_ID
WHERE P.P_ID = 1
ORDER BY R.CREATE_TIME DESC;	
	
-- 테스트
--SELECT P_ID, P_NAME, COST_PRICE, REGULAR_PRICE, SELLING_PRICE, P_QTY, INGREDIENT, CATEGORY, REG_TIME, SELLING_STATE, IMAGEPATH FROM PRODUCT
--FROM product
--WHERE ROWNUM BETWEEN 1 AND 8;

--SELECT P_ID, P_NAME, COST_PRICE, REGULAR_PRICE, SELLING_PRICE, P_QTY, INGREDIENT, CATEGORY, REG_TIME, SELLING_STATE, IMAGEPATH
--FROM PRODUCT
--WHERE ROWNUM BETWEEN 79 AND 90
--AND SELLING_STATE = '판매중';

--상품 판매상태 변경
UPDATE PRODUCT
SET SELLING_STATE = '판매중지'
WHERE P_ID = 1;