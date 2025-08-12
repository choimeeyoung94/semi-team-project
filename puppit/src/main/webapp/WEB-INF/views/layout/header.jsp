<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- Font Awesome 라이브러리 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<style>
/* 전체 헤더 한 줄 */
.header{
  display:flex;
  justify-content:space-between;
  align-items:flex-start;
  max-width:1200px;
  margin:0 auto;
  padding:16px 20px;
}

/* 왼쪽 영역: 세로로 로고, 검색창, 카테고리 */
.left{
  display:flex;
  align-items:flex-start;
  gap:18px;
}
.left-col{                /* 로고 오른쪽에 쌓일 컬럼 */
  display:flex;
  flex-direction:column;
  gap:14px;
  min-width:420px;        /* 검색창 너비 확보 */
}

/* 검색창 (아이콘 포함, 밝은 배경) */
.searchBar{
  position:relative;
  width:100%;
  max-width:600px;
}
.searchBar .input{
  width:100%;
  height:44px;
  padding:0 44px 0 40px;
  border:1px solid #e5e7eb;
  border-radius:12px;
  background:#f5f7fa;
  outline:none;
}
.searchBar .fa-magnifying-glass{
  position:absolute; left:14px; top:50%; transform:translateY(-50%); color:#666;
}
.searchBar .fa-keyboard{
  position:absolute; right:14px; top:50%; transform:translateY(-50%); color:#666;
}

/* 카테고리 선택 + 빠른링크 */
.meta-row{
  display:flex;
  align-items:center;
  gap:16px;
}
.category{
  position:relative;
  display:inline-flex;
  align-items:center;
  gap:10px;
  padding:10px 14px;
  border:1px solid #e5e7eb;
  border-radius:12px;
  background:#fff;
  cursor:pointer;
}
.category select{
  appearance:none;      /* 기본 화살표 숨기기 */
  border:none;
  background:transparent;
  font:inherit;
  outline:none;
  padding-right:22px;   /* 오른쪽 화살표 자리 */
}
.category .chev{
  position:absolute; right:10px;
  pointer-events:none;
  color:#444;
  font-size:12px;
}

/* 오른쪽 버튼 스택 */
.right{
  display:flex;
  flex-direction:column;
  align-items:flex-end;
  gap:12px;
 

}
a {
  text-decoration: none;
  color: inherit; /* 부모 색상 따라감 */
}

.top-actions{
  display:flex; gap:10px;
}
.btn{
  padding:6px 12px;
  border:1px solid #d1d5db;
  border-radius:8px;
  background:#fff;
  cursor:pointer;
}
.btn.dark{
  background:#111; color:#fff; border-color:#111;
}
.bottom-actions{
  display:flex; gap:10px;
}

/* 카테고리 리스트(nav) – 깔끔하게 */
nav ul{ list-style:none; padding:0; margin:24px 20px; display:flex; gap:18px; }
nav a{ text-decoration:none; color:#374151; }
nav a:hover{ text-decoration:underline; }
</style>

<div class="header">
  <!-- 왼쪽: 로고 + 검색 + 카테고리 -->
  <div class="left">
    <div class="logo">
      <img src="${contextPath}/resources/image/DOG.jpg" width="100px" alt="puppit">
    </div>

    <div class="left-col">
      <div class="searchBar">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" class="input" placeholder="검색어를 입력하세요">
        <i class="fa-solid fa-keyboard"></i>
      </div>

      <div class="meta-row">
        <label class="category">
          <select>
            <option>강아지용품</option>
            <option>산책용품</option>
            <option>강아지 의류</option>
            <option>강아지 사료</option>
            <option>기타용품</option>
          </select>
          <i class="fa-solid fa-chevron-down chev"></i>
        </label>

        <!-- 필요하면 빠른 링크들 -->
        <a href="${contextPath}/category?type=walk" style="color:#ef4444; font-size:14px;">산책용품</a>
        <a href="${contextPath}/category?type=food" style="color:#6b7280; font-size:14px;">강아지 사료간식</a>
      </div>
    </div>
  </div>

  <!-- 오른쪽: 버튼(링크) -->
  <div class="right">
  <c:choose>
    <c:when test="${empty sessionScope.userId}">
      <div class="top-actions">
        <a href="${contextPath}/user/login" class="btn">login</a>
        <a href="${contextPath}/user/signup" class="btn">Sign up</a>
      </div>
    </c:when>
    <c:otherwise>
      <span>${sessionScope.userName}님 환영합니다!</span>
      <a href="${contextPath}/user/mypage">마이페이지</a>
      <a href="${contextPath}/user/logout">로그아웃</a>
    </c:otherwise>
  </c:choose>
  
    <div class="bottom-actions">
      <a href="${contextPath}/myproduct" class="btn dark">상품 관리</a>
    </div>
  </div>
</div>

<nav>
  <ul>
    <li><a href="${contextPath}/category?type=walk">산책용품</a></li>
    <li><a href="${contextPath}/category?type=wear">강아지 의류</a></li>
    <li><a href="${contextPath}/category?type=food">강아지 사료</a></li>
    <li><a href="${contextPath}/category?type=etc">기타용품</a></li>
  </ul>
</nav>

  <hr>

