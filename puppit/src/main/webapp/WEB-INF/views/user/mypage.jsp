<%@ page language="java" contentType="text/html; charset=UTF-8"
  pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<jsp:include page="../layout/header.jsp">
  <jsp:param value="Home" name="title" />
</jsp:include>

<style>
:root {
  --bg: #fff;
  --card: #fff;
  --text: #111;
  --muted: #8a8f98;
  --primary: #333333;
  --line: #dfe3ea;
  --shadow: 0 8px 24px rgba(0, 0, 0, .08);
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background: var(--bg);
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
  color: var(--text);
}

.wrap {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.topbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
}

.back-btn {
  border: none;
  background-color: #fff;
  font-size: 20px;
  color: #333;
  cursor: pointer;
}

.title {
  font-weight: 700;
  font-size: 20px;
}

/* 프로필 카드 */
.profile {
  display: flex;
  align-items: center;
  gap: 16px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 16px;
  box-shadow: var(--shadow);
}

.avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  overflow: hidden;
  flex: 0 0 64px;
  border: 2px solid #eee;
  background: #fafafa;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.who {
  flex: 1;
}

.nick {
  font-weight: 700;
  font-size: 18px;
}

/* 포인트 카드 — 살짝 컴팩트 */
.point-card {
  margin-top: 18px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 20px;
  padding: 18px;
  box-shadow: var(--shadow);
}

.point-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.point-title {
  font-weight: 800;
  font-size: 18px;
}

.point-row {
  display: flex;
  align-items: center;
  justify-content: space-between; 
  gap: 12px;
  margin: 8px 0 16px;
}

.p-icon {
  width: 35px;
  height: 35px;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
}

.p-icon img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.point-amount{
  display:flex;
  align-items:center;
  gap:12px;
}

.p-amount{
  font-size:28px;      
  font-weight:800;     
  line-height:1;
  white-space:nowrap;  
}

.charge { width: auto; height: 44px; padding: 0 16px; border-radius: 12px; }

.charge-inline {
  height: 44px;           
  padding: 0 16px;       
  border-radius: 12px;   
}

.charge:active {
  transform: translateY(1px);
}

/* 아래 확장 공간 */
.future-area {
  margin-top: 18px;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 20px;
  padding: 18px;
  box-shadow: var(--shadow);
}

/* 반응형 */
@media (min-width: 768px) {
  .avatar {
    width: 72px;
    height: 72px;
  }
  .p-amount {
    font-size: 32px;
    font-weight:800;
  }
}

/* 액션 카드 (내역 보기) */
.action-grid {
  width: 100%;
  max-width: 1200px;
  display: grid;
  gap: 12px;
}

.action-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 16px;
  box-shadow: var(--shadow);
}

.action-title {
  font-weight: 700;
  font-size: 16px;
}

.action-desc {
  color: var(--muted);
  font-size: 13px;
  margin-top: 4px;
}

.action-btn {
  height: 44px;
  padding: 0 16px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  background: #fff;
  color: var(--text);
  font-weight: 800;
  border: 1px solid var(--line);
  box-shadow: none;
}

.action-btn:active {
  transform: translateY(1px);
}
</style>

<div class="wrap">
  <div class="topbar">
    <button class="back-btn" onclick="history.back()" aria-label="뒤로가기">
      <i class="fa-solid fa-arrow-left"></i>
    </button>
    <div class="title">마이페이지</div>
  </div>

  <!-- 프로필 -->
  <div class="profile">
    <div class="avatar">
      <img src="${contextPath}/resources/image/${sessionScope.sessionMap.userId}.png" alt="프로필 이미지" />
    </div>
    <div class="who">
      <div class="nick">${user.nickName != null ? user.nickName : 'happy'}</div>
    </div>
    <button class="action-btn" type="button" onclick="location.href='${contextPath}/user/profile'">프로필 수정</button>
  </div>
  
    <!-- 찜 목록 카드 -->
  <div class="action-card" style="margin-top: 18px;">
    <div>
      <div class="action-title"><i class="fa-solid fa-heart"></i> 찜 목록</div>
      <div class="action-desc">내가 찜한 상품을 확인해보세요</div>
    </div>
    <button class="action-btn" type="button" onclick="location.href='${contextPath}/wish/list?userId=${user.userId}'">목록 보기</button>
  </div>
  

  <!-- 포인트 카드 (컴팩트) -->
  <div class="point-card">
    <div class="point-head">
      <div class="point-title">포인트</div>
    </div>
    <div class="point-row">
      <div class="point-amount">
        <div class="p-icon"><img src="${contextPath}/resources/image/point-icon.png" alt="포인트" /></div>
        <div class="p-amount">
          <c:choose>
            <c:when test="${not empty user.point}">
              <fmt:formatNumber value="${user.point}" type="number" />
            </c:when>
            <c:otherwise>0</c:otherwise>
          </c:choose>
        </div>
      </div>
    
      <button class="action-btn charge-inline" type="button"
              onclick="location.href='${contextPath}/payment/paymentForm'">충전하기</button>
    </div>
        
  </div>

  <div class="future-area">
    <div class="action-grid">
      <!-- 포인트 충전 내역 -->
      <div class="action-card">
        <div>
          <div class="action-title">포인트 충전 내역</div>
          <div class="action-desc">최근 충전 기록을 확인하세요</div>
        </div>
        <button class="action-btn" type="button" onclick="location.href='${contextPath}/payment/history?userId=${user.userId}'">내역 보기</button>
      </div>

      <!-- 거래 내역 -->
      <div class="action-card">
        <div>
          <div class="action-title">거래 내역</div>
          <div class="action-desc">구매·판매 기록을 한눈에</div>
        </div>
        <button class="action-btn" type="button" onclick="location.href='${contextPath}/trade/history?userId=${user.userId}'">내역 보기</button>
      </div>
    </div>
  </div>
</div>

</body>
</html>