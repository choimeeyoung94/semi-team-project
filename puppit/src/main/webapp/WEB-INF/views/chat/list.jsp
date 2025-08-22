<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%
Map<String, Object> sessionMap = (Map<String, Object>) session.getAttribute("sessionMap");
String accountId = "";
Integer userId = 0;
if (sessionMap != null) {
    Object accountIdObj = sessionMap.get("accountId");
    if (accountIdObj != null) {
        accountId = accountIdObj.toString();
    }
    Object userIdObj = sessionMap.get("userId");
    if (userIdObj != null) {
        userId = Integer.parseInt(userIdObj.toString());
    }
}
%>

<c:set var="loginUserId" value="<%= accountId %>" />
<c:set var="userId" value="<%=userId %>"/>
<c:set var="highlightRoomIdStr" value="${highlightRoomIdStr}"/>
<jsp:include page="/WEB-INF/views/layout/header.jsp?dt=<%=System.currentTimeMillis()%>"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 목록</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
     body { font-family: 'Noto Sans KR', sans-serif; background: #fff; margin: 0; padding: 0; }
		.container {
		    max-width: 1200px;
		    width: 100%;
		    min-height: 700px;
		    padding-top: 100px;
		    display: flex;
		    flex-direction: row;
		    gap: 0;
		    justify-content: center;
		    align-items: flex-start;
		    margin: 0 auto;
		    background: #fff;
		    box-sizing: border-box;
		}
		
		/* 채팅목록 영역 50% */
		.chatlist-container {
		    width: 50%;
		    min-width: 0;
		    height: 600px;
		    border: none;
		    padding: 0;
		    margin: 0;
		    overflow-y: auto;
		    box-sizing: border-box;
		}
		
		/* 채팅창 영역 50% */
		.chat-container {
		    width: 50%;
		    min-width: 0;
		    height: 600px;
		    display: flex;
		    flex-direction: column;
		    justify-content: flex-end;
		    padding: 20px;
		    box-sizing: border-box;
		    background: #fafafa;
		}
        .chat-list { display: flex; flex-direction: column; gap: 20px; }
        .chatList { display: flex; flex-direction: row; align-items: center; padding: 0 10px; gap: 16px; cursor: pointer; background: #fff; border-radius: 18px; min-height: 80px; transition: background 0.15s; box-shadow: none; border: none; }
        .chatList:hover { background: #f5f5f5; }
        .chat-profile-img { width: 56px; height: 56px; border-radius: 50%; object-fit: cover; margin-right: 10px; border: 1.5px solid #eee; background: #fafafa; display: flex; justify-content: center; align-items: center; font-size: 28px; color: #bbb; }
        .chat-info-area { flex: 1 1 0; display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .chat-nickname { font-size: 18px; font-weight: 700; color: #222; margin-bottom: 2px; letter-spacing: -0.5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .chat-message { font-size: 15px; color: #444; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 220px; }
        .chat-meta { display: flex; flex-direction: column; align-items: flex-end; min-width: 90px; gap: 8px; }
        .chat-time { font-size: 14px; color: #757575; font-weight: 400; }
        .chat-unread-badge { display: inline-block; width: 22px; height: 22px; line-height: 20px; font-size: 15px; background: #fff; color: #e74c3c; border: 2px solid #e74c3c; border-radius: 50%; text-align: center; font-weight: 700; margin-top: 2px; margin-right: 5px; }
        .chat-history { display: flex; flex-direction: column; align-items: flex-start; width: 100%; gap: 12px; margin-bottom: 16px; overflow-y: auto; flex: 1; scrollbar-width: none; -ms-overflow-style: none; }
        .chat-history::-webkit-scrollbar { display: none; }
        .chat-history .chat-message { max-width: 60%; min-width: 80px; padding: 10px 16px; border-radius: 12px; margin-bottom: 4px; display: flex; flex-direction: column; background: #eee; box-sizing: border-box; word-break: break-word; height: auto; overflow: visible; }
        .chat-history .chat-message.right { align-self: flex-end !important; background: #e9f7fe; text-align: right; }
        .chat-history .chat-message.left { align-self: flex-start !important; background: #eee; text-align: left; }
        .chat-history .chat-message .chat-userid { font-size: 13px; color: #888; margin-bottom: 2px; }
        .chat-history .chat-message .chat-text { font-size: 15px; margin-bottom: 2px; white-space: pre-wrap; overflow-wrap: break-word; word-break: break-word; }
        .chat-history .chat-message .chat-time { font-size: 12px; color: #aaa; margin-top: 2px; align-self: flex-end; }
        .chatList.highlight { background: #fff8e1; border: 2px solid #ffb300; }	
        .center-message { text-align:center; margin:20px 0; color:#888; }
        .notification {
	        position: fixed;
	        right: -100px;
	        top: 20px;
	        width: 300px;
	        background-color: #f9f9f9;
	        border: 1px solid #ccc;
	        padding: 10px;
	        border-radius: 5px;
	        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
	        transition: right 1s;
	    }

		/* 반응형 대응: 모바일 화면에서는 100%로 */
		@media (max-width: 1200px) {
		    .container { max-width: 100vw; }
		    .chatlist-container, .chat-container { width: 100%; }
		    .container { flex-direction: column; }
		}
        /* 채팅이 두 번 이상 이루어졌을 때 보이는 결제하기 버튼(#pay-btn)의 스타일 오버라이드 */
		#pay-btn {
		  background: #000 !important;    /* 검정색 배경 */
		  color: #fff !important;         /* 흰색 글자 */
		  border: none !important;
		  width: 200px !important;        /* 너비 200px */
		  height: 50px !important;        /* 높이 50px */
		  font-size: 20px;
		  font-weight: 700;
		  border-radius: 8px;
		  cursor: pointer;
		  box-shadow: 0 2px 8px rgba(25, 25, 25, 0.15);
		  text-align: center;
		  display: inline-block;
		  margin-top: 10px;
		  transition: background 0.2s;
		}
		
		#pay-btn:hover {
		  background: #222 !important;    /* 호버시 어두운 회색 */
		}
		/* 채팅 입력 textarea 스타일 */
        .chat-input-group textarea#chatMessageInput {
            width: 400px;
            height: 100px;
            resize: none;
            font-size: 16px;
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid #d1d5db;
            box-sizing: border-box;
            margin-right: 12px;
            font-family: 'Noto Sans KR', sans-serif;
            line-height: 1.5;
        }
        /* 전송 버튼 스타일 */
        .chat-input-group button {
            width: 200px;
            height: 50px;
            background: #000 !important;
            color: #fff !important;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }
        .chat-input-group button#sendChatButton:hover {
            background: #222 !important;
        }
        .chat-input-group {
            display: flex;
            flex-direction: row;
            align-items: flex-end;
            gap: 12px;
            margin-top: 8px;
        }
    </style>
</head>
<body>
<div class="container">
   
    
    <div class="chatlist-container" id="chatlist-container">
     
        <div style="display: flex; align-items: center; margin-bottom: 12px; box-sizing: border-box;">
            <button id="back-btn"
                style="background: none; border: none; color: #222; font-size: 24px; font-weight: 700; cursor: pointer; padding: 0; margin-right: 8px; display: flex; align-items: center;">
                <i class="fa-solid fa-arrow-left" style="font-size: 24px;"></i>
            </button>
            
        </div>
        <div id="chatListRenderArea">
	         <div style="text-align: center; font-size: 22px; font-weight: 700; color: #222; margin-bottom: 16px;">
	            채팅방목록
	        </div>
        
            <c:forEach items="${chatList}" var="chat">
                <div class="chatList" data-room-id="${chat.roomId}">
                    <span class="chat-profile-img chat-profile-icon">
                        <i class="fa-solid fa-user"></i>
                    </span>
                    <div class="chat-info-area" style="cursor:pointer;">
                        <div class="chat-nickname">
                             <c:choose>
                                <c:when test="${not empty chat.productName}">
                                    <c:out value="${chat.productName}" />  (<c:out value="${chat.sellerAccountId}" />)
                                </c:when>
                                <c:otherwise>
                                    상품판매자와 채팅을 시작해보세요
                                </c:otherwise>
                            </c:choose>
                        </div>
                         
                        <div class="chat-message">
                            <c:choose>
                                <c:when test="${not empty chat.lastMessage}">
                                    <c:out value="${chat.lastMessage}" />
                                </c:when>
                                <c:otherwise>
                                    상품판매자와 채팅을 시작해보세요
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    <div class="chat-container">
        <div class="product-info-area" id="product-info-area"></div>
        <div class="center-message" id="center-message">상품 판매자와 채팅을 시작해보세요</div>
        <div class="chat-history" id="chat-history"></div>
        <div class="chat-input-group">
             <textarea id="chatMessageInput" placeholder="채팅메시지를 입력하세요" rows="5"></textarea>
            <button type="submit"  id="sendChatButton">전송</button>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.2/stomp.min.js"></script>
<script>

const centerMessage = document.getElementById('center-message');
const chatHistory = document.getElementById('chat-history');
const productInfoArea = document.getElementById('product-info-area');
const renderedMessageIds = new Set();
console.log("contextPath", contextPath);
console.log("loginUserId", loginUserId);
console.log("userId", userId);

//let stompClient = null;
let currentRoomId = null;
let currentSubscription = null;
let isConnected = false;
let productId = null;
let buyerId = null;
let buyerAccountId = "";
//3. 채팅방 접속자 관리 (프론트 전역)
let activeRooms = {}; // { roomId: { buyer: true/false, seller: true/false } }
//하이라이트 타이머 관리용 객체
let highlightTimers = {}; // { roomId: timerId }

document.addEventListener('DOMContentLoaded', function() {
    //const chatlist = document.getElementById('chatlist-container');
    const urlParams = new URLSearchParams(window.location.search);
    const highlightRoomId = urlParams.get('highlightRoomId');
    const highlightMessage = urlParams.get('highlightMessage');
    
    if (highlightRoomId) {
        highlightChatRoom(highlightRoomId);
        if (highlightMessage) {
          updateChatListLastMessage(highlightRoomId, highlightMessage);
        }
      }
    
    //chatlist.addEventListener('click', function(e) {
      //  const chatDiv = e.target.closest('.chatList');
       // if (chatDiv) {
        //    const roomId = chatDiv.dataset.roomId;
        //    currentRoomId = roomId;
        //    if (roomId) {
        //        loadChatHistory(roomId).then(() => {
        //            connectAndSubscribe(roomId);
        //        });
        //    }
       // }
    //});
    
    
    const chatlist = document.getElementById('chatlist-container');
    if (chatlist) {
        chatlist.addEventListener('click', function(e) {
            // e.target.closest('.chatList')로 클릭된 채팅방 div 탐색
            const chatDiv = e.target.closest('.chatList');
            if (chatDiv) {
                const roomId = chatDiv.dataset.roomId;
                currentRoomId = roomId;
                highlightChatRoom(roomId);
                if (roomId) {
                    loadChatHistory(roomId).then(() => {
                        connectAndSubscribe(roomId);
                    });
                }
            }
        });
    }

    const sendBtn = document.getElementById('sendChatButton');
    if (sendBtn) {
        sendBtn.addEventListener('click', function(e){
            e.preventDefault();
            sendMessage(currentRoomId);
        });
    }
    enableChatInput(false);
});

function enableChatInput(enable) {
    const input = document.querySelector('input[placeholder="채팅메시지를 입력하세요"]');
    const button = document.querySelector('button[type="submit"]');
    if (input && button) {
        input.disabled = !enable;
        button.disabled = !enable;
    }
}


function loadChatHeader(product, buyerId, sellerId, sellerAccountId, buyerAccountId) {
    const chatHeader = document.getElementById('chat-header');
    console.log('loadChatHeader 호출됨');
    console.log('chatHeader:', chatHeader);
    console.log('buyerId:', buyerId, 'sellerId:', sellerId, 'sellerAccountId:', sellerAccountId, 'buyerAccountId:', buyerAccountId);

    // sellerAccountId와 buyerAccountId를 안전하게 처리
    const sellerText = typeof sellerAccountId === 'string' && sellerAccountId.trim() !== '' ? sellerAccountId : "정보 없음";
    const buyerText = typeof buyerAccountId === 'string' && buyerAccountId.trim() !== '' ? buyerAccountId : "구매자 계정 정보 없음";

    if (String(userId) === String(buyerId)) {
        // 현재 사용자가 구매자인 경우
        chatHeader.innerHTML = `<strong>상품 판매자:</strong> ${sellerText}`;
    } else if (String(userId) === String(sellerId)) {
        // 현재 사용자가 판매자인 경우
        chatHeader.innerHTML = `<strong>구매자:</strong> ${buyerText}`;
    } else {
        // 알 수 없는 역할일 경우 기본 메시지 표시
        chatHeader.innerHTML = `<strong>채팅 상대 정보를 불러올 수 없습니다.</strong>`;
    }
}

function loadChatHistory(roomId) {
    return fetch(contextPath + '/chat/message?roomId=' + roomId)
        .then(response => response.json())
        .then(data => {
            console.log('Server Response:', data); // 서버 응답 로그 출력
            chatHistory.innerHTML = "";
            renderedMessageIds.clear();
            
            buyerId = null;
            buyerAccountId = "";
            const sellerId = data.product.sellerId || null; // 판매자 ID
            const sellerAccountId = data.product.chatSellerAccountId || ""; // 판매자의 accountId
            //let buyerAccountId = ""; // 구매자의 accountId 초기화

           // === buyerId와 buyerAccountId 추출 ===
            if (Array.isArray(data.chatMessages) && data.chatMessages.length > 0) {
                // BUYER가 보낸 메시지 중 첫 번째에서 buyer 정보 추출
                const buyerMessage = data.chatMessages.find(msg => msg.senderRole === "BUYER");
                if (buyerMessage) {
                    buyerId = buyerMessage.buyerId || buyerMessage.chatSender || null;
                    buyerAccountId = buyerMessage.chatSenderAccountId || "";
                }
            }
         	// 만약 위에서 못 찾았으면 product에서 시도 (없으면 null/"")
            if (!buyerId && data.product && data.product.buyerId) {
                buyerId = data.product.buyerId;
            }
            if (!buyerAccountId && data.product && data.product.buyerAccountId) {
                buyerAccountId = data.product.buyerAccountId;
            }
            
            // ★ 추가: 전역 저장!
            window.buyerId = buyerId;
            window.buyerAccountId = buyerAccountId;
            
            
            // ★ 여기에 추가!
            window.lastProductInfo = data.product;
            
            
            // 디버깅 출력
            console.log("buyerId: ", buyerId, " sellerId: ", sellerId, " sellerAccountId: ", sellerAccountId, " buyerAccountId: ", buyerAccountId);

            renderProductInfo(data.product, data.chatMessages || []);

            const messages = Array.isArray(data.chatMessages) ? data.chatMessages : [];
            messages.forEach(chat => {
                addChatMessageToHistory(chat);
            });

            centerMessage.style.display = messages.length > 0 ? "none" : "block";
        });
}
function renderProductInfo(product, chatMessages) {
	  console.log('Rendering Product Info:', product); // 서버에서 전달된 product 확인
    const price = Number(product.productPrice);
    let html =
        '<div style="margin-bottom:10px; border-bottom:1px solid #eee; padding-bottom:12px;">'
        + '<strong>상품명:</strong> ' + product.productName + '<br>'
        + '<strong>가격:</strong> ' + (isNaN(price) ? product.productPrice : price.toLocaleString()) + '원 <br>';

     // === 구매자와 판매자가 2번 이상 대화했을 때만 결제 버튼 표시 ===
     // 대화는 BUYER, SELLER가 번갈아 보내야 하므로, 두 사람 모두 최소 1번 이상 메시지를 보냈는지 확인
     let buyerCount = 0, sellerCount = 0;
     if (Array.isArray(chatMessages)) {
            chatMessages.forEach(msg => {
                if (msg.senderRole === "BUYER") buyerCount++;
                if (msg.senderRole === "SELLER") sellerCount++;
            });
     }  
        
        
        
    // 🔥 로그인된 사용자와 판매자가 다른 경우 결제 버튼 추가
    if ( chatMessages.length >= 2) {
        html += `<button
            id="pay-btn"
            	    data-buyer-id="\${userId}" // 로그인된 사용자를 buyerId로 설정
                    data-seller-id="\${product.sellerId}"
                    data-seller-account-id="\${product.chatSellerAccountId}" // Fix: Bind chatSellerAccountId directly from product object
                    data-product-name="\${product.productName}"
                    data-product-id="\${product.productId}"
        >결제하기</button>`;
    }

    html += '</div>';
    productInfoArea.innerHTML = html;

    const payBtn = document.getElementById('pay-btn');
    if (payBtn) {
        payBtn.onclick = function(e) {
            const btn = e.currentTarget;
            console.log("btn.dataset: ", btn.dataset); // 버튼 데이터 확인
            const buyerId = btn.dataset.buyerId; // buyerId 가져오기

            // 반드시 data-seller-account-id를 읽어서 콘솔에 찍음!
            const chatSellerAccountId = btn.dataset.sellerAccountId; // Fix: Access chatSellerAccountId from dataset
            console.log('결제버튼 클릭 - chatSellerAccountId:', chatSellerAccountId);
            const quantity = 1;
            const productId = product.productId;
            const payUrl = contextPath + '/order/pay'
            	+ '?buyerId=' + encodeURIComponent(buyerId)
                + '&sellerId=' + encodeURIComponent(product.sellerId)
                + '&chatSellerAccountId=' + encodeURIComponent(chatSellerAccountId)
                + '&productName=' + encodeURIComponent(product.productName)
                + '&productId=' + encodeURIComponent(product.productId)
                + '&quantity=' + encodeURIComponent(quantity);
            window.location.href = payUrl;
        };
    }
}

function addChatMessageToHistory(chat) {
    const productSellerId = document.querySelector('#pay-btn')?.dataset.sellerId; // 판매자 ID 가져오기
    const currentUserRole = (String(userId) === String(productSellerId)) ? "SELLER" : "BUYER"; // 현재 사용자 역할 결정

 	// 이미 렌더링된 메시지는 건너뜀
    if (chat.messageId && renderedMessageIds.has(chat.messageId)) {
        return;
    }
    if (chat.messageId) renderedMessageIds.add(chat.messageId);

    
    // 메시지를 보낸 사람과 현재 사용자를 비교하여 영역 결정
    if (String(chat.chatSenderAccountId) === String(loginUserId)) {
        // 현재 사용자가 메시지를 보낸 경우
        let alignClass = "right"; // 오른쪽 정렬
        let msg = chat.message || chat.chatMessage || "";

        // 시간을 yyyy-MM-dd a hh:mm:ss 형식으로 변환
        let formattedTime = formatChatTime(chat.chatCreatedAt || "");

        let html =
            '<div class="chat-message ' + alignClass + '">' +
                '<div class="chat-userid">' + (chat.chatSenderAccountId || "") + '</div>' +
                '<div class="chat-text">' + msg + '</div>' +
                '<div class="chat-time">' + formattedTime + '</div>' +
            '</div>';
        chatHistory.innerHTML += html;
    } else {
        // 상대방이 메시지를 보낸 경우
        let alignClass = "left"; // 왼쪽 정렬
        let msg = chat.message || chat.chatMessage || "";

        // 시간을 yyyy-MM-dd a hh:mm:ss 형식으로 변환
        let formattedTime = formatChatTime(chat.chatCreatedAt || "");

        let html =
            '<div class="chat-message ' + alignClass + '">' +
                '<div class="chat-userid">' + (chat.chatSenderAccountId || "") + '</div>' +
                '<div class="chat-text">' + msg + '</div>' +
                '<div class="chat-time">' + formattedTime + '</div>' +
            '</div>';
        chatHistory.innerHTML += html;
    }

    // 스크롤을 최신 메시지로 이동
    chatHistory.scrollTop = chatHistory.scrollHeight;
}


//시간 형식 변환 함수 추가
function formatChatTime(timeString) {
    if (!timeString) return "시간 정보 없음";
    if (/^\d+$/.test(timeString)) {
        const date = new Date(Number(timeString));
        if (!isNaN(date.getTime())) {
            return date.toLocaleString("ko-KR", {
                year: "numeric", month: "2-digit", day: "2-digit",
                hour: "2-digit", minute: "2-digit", second: "2-digit",
                hour12: true
            });
        }
    }
    let date = new Date(timeString);
    console.log('date: ', date);
    if (isNaN(date.getTime()) && timeString.includes('+09:00')) {
        date = new Date(timeString.replace('+09:00', 'Z'));
    }
    if (!isNaN(date.getTime())) {
        return date.toLocaleString("ko-KR", {
            year: "numeric", month: "2-digit", day: "2-digit",
            hour: "2-digit", minute: "2-digit", second: "2-digit",
            hour12: true
        });
    }
    return "시간 정보 없음";
}


function connectAndSubscribe(currentRoomId) {
    if (!stompClient) {
        const socket = new SockJS(contextPath + '/ws-chat');
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function() {
            isConnected = true;
            subscribeRoom(currentRoomId);
            enableChatInput(true);
            //subscribeNotifications(); // 알림 구독
            console.log("[DEBUG] enableChatInput(true) called");
             
        });
    } else {
    	// 이미 연결된 경우에도 반드시 isConnected = true로 보완!
        if (stompClient.connected) {
            isConnected = true; // ★ 추가!
        }
        subscribeRoom(currentRoomId);
        enableChatInput(true);
        //subscribeNotifications(); // 알림 구독
        console.log("[DEBUG] enableChatInput(isConnected) called", isConnected);
    }
}





function subscribeRoom(currentRoomId) {
	if (currentSubscription) currentSubscription.unsubscribe();
    currentSubscription = stompClient.subscribe('/topic/chat/' + currentRoomId, function (msg) {
        const chat = JSON.parse(msg.body);
       
        let rawTime = chat.chatCreatedAt || "";
        console.log("addChatMessageToHistory: rawTime =", rawTime, typeof rawTime);
       
         // === 하이라이트 처리 코드 START ===
        // 메시지 송신자 역할
        const senderRole = chat.senderRole; // "BUYER" 또는 "SELLER"
        
        // 현재 사용자 역할
        let currentUserRole = (String(userId) === String(chat.chatSender)) ? senderRole : (senderRole === "BUYER" ? "SELLER" : "BUYER");

        // 구매자/판매자 접속자 기록
        setUserInRoom(chat.chatRoomId, senderRole);
        setUserInRoom(chat.chatRoomId, currentUserRole);

        // === 하이라이트 처리 코드 START ===
        // 메시지의 수신자가 현재 로그인한 사용자일 때만 하이라이트!
        // userId(숫자)와 chat.chatReceiver(숫자) 또는
        // loginUserId(문자열)와 chat.chatReceiverAccountId(문자열) 비교
        if (
        		String(chat.chatReceiver) === String(userId) ||
        	     String(chat.chatReceiverAccountId) === String(loginUserId)
        	    && String(chat.chatSenderAccountId) !== String(loginUserId) 
        ) {
            highlightChatRoom(chat.chatRoomId);
        } else {
            removeHighlightChatRoom(chat.chatRoomId);
        }
        // === 하이라이트 처리 코드 END ===
        
       if (String(currentRoomId) === String(chat.chatRoomId)) {
            addChatMessageToHistory(chat);
            centerMessage.style.display = "none";
             // === 결제버튼 갱신을 위해 상품영역 재렌더링 ===
            // chatHistory.innerHTML에 메시지 추가 후, product, chatMessages를 다시 계산
            // window.lastProductInfo, chatHistory에서 메시지 목록 추출
            if (window.lastProductInfo) {
                // 채팅 메시지 목록을 chatHistory에서 직접 추출 (이미 렌더링된 메시지들)
                // 하지만 서버에서 내려온 chatMessages가 최신일 수 있으니, 아래처럼 메시지 배열 관리가 필요
                // 간단하게: chatHistory에 있는 메시지들을 모을 수도 있지만, 
                // 최신 메시지(chat)까지 포함하여 productInfoArea 갱신
                // 기존 채팅방 메시지 배열이 있으면 거기에 push
                if (!window.currentChatMessages) window.currentChatMessages = [];
                window.currentChatMessages.push(chat);

                // productInfoArea 재렌더링
                renderProductInfo(window.lastProductInfo, window.currentChatMessages);
            }
            
            
            
        } else if (!isMine) {
            // 수신자인 경우에만 알림 표시
            displayNotification(
                chat.chatSenderAccountId,
                chat.chatMessage,
                chat.senderRole,
                chat.chatCreatedAt,
                chat.productName
            );
        }
    });
}

function subscribeNotifications() {
	 stompClient.subscribe('/topic/notification', function(notification) {
    const data = JSON.parse(notification.body);

    // receiverAccountId가 로그인된 사용자와 같을 때만 표시
    if (String(data.receiverAccountId) !== String(loginUserId)) {
      return;
    }
    displayNotification(
      data.senderAccountId,
      data.chatMessage,
      data.senderRole,
      data.chatCreatedAt,
      data.productName
    );
  });
}

function displayNotification(senderAccountId, chatMessage, senderRole, chatCreatedAt, productName) {
    console.log('senderAccountId: ', senderAccountId);
    console.log('chatMessage: ', chatMessage);
    console.log('senderRole: ', senderRole);
    console.log('chatCreatedAt: ', chatCreatedAt);
    console.log('productName: ', productName);
	const notification = document.createElement('div');
    notification.className = 'notification';
    notification.innerHTML = `
        <strong>${senderRole}:</strong> ${chatMessage}<br>
        <small>${chatCreatedAt} - ${productName}</small>
    `;
    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.right = '20px';
    }, 100);

    setTimeout(() => {
        notification.remove();
    }, 120000);
}

function enableChatInput(enable) {
    const input = document.querySelector('input[placeholder="채팅메시지를 입력하세요"]');
    const button = document.querySelector('button[type="submit"]');
    if (input && button) {
        input.disabled = !enable;
        button.disabled = !enable;
    }
}

function getCurrentChatTime() {
	return new Date().toISOString(); // 예: "2025-08-21T13:23:59.000Z"
}


//1. 채팅방 하이라이트 함수
function highlightChatRoom(roomId) {
	const chatLists = document.querySelectorAll('.chatList');
	  chatLists.forEach(chatDiv => {
	    if (String(chatDiv.dataset.roomId) === String(roomId)) {
	      chatDiv.classList.add('highlight');
	      // 2초 후 하이라이트 제거
	      if (highlightTimers[roomId]) clearTimeout(highlightTimers[roomId]);
	      highlightTimers[roomId] = setTimeout(() => {
	        chatDiv.classList.remove('highlight');
	        highlightTimers[roomId] = null;
	      }, 2000);
	    }
	  });
    
}

//2. 하이라이트 제거 함수
function removeHighlightChatRoom(roomId) {
    const chatLists = document.querySelectorAll('.chatList');
    chatLists.forEach(chatDiv => {
        if (String(chatDiv.dataset.roomId) === String(roomId)) {
            chatDiv.classList.remove('highlight');
        }
    });
}

//4. 채팅방 입장시 접속자 기록 (간단 예시, 실제는 서버에서 WebSocket으로 관리)
function setUserInRoom(roomId, role) {
    if (!activeRooms[roomId]) activeRooms[roomId] = { buyer: false, seller: false };
    activeRooms[roomId][role.toLowerCase()] = true;
}




function sendMessage(currentRoomId) {
	 console.log("sendMessage called", {
	      stompClient,
	      isConnected,
	      currentRoomId,
	      input: document.querySelector('input[placeholder="채팅메시지를 입력하세요"]'),
	      message: document.getElementById('chatMessageInput') ? document.getElementById('chatMessageInput').value : ''
	    });
	 const input = document.getElementById('chatMessageInput');
	 if (!input) {
        alert("채팅 입력창을 찾을 수 없습니다.");
        return;
    }
    const message = input.value;
    if (!stompClient || !isConnected) return;
    if (!message.trim() || !currentRoomId) return;
    if (!stompClient || !isConnected) return;
 
    
    if (!message.trim() || !currentRoomId) return;

    // 버튼에서 값 추출
    let productSellerId = document.querySelector('#pay-btn')?.dataset.sellerId;
    let productSellerAccountId = document.querySelector('#pay-btn')?.dataset.sellerAccountId;
    console.log('productSellerId: ', productSellerId);

    // 버튼이 없으면, productInfoArea에서 직접 값 추출
    if (!productSellerId || !productSellerAccountId) {
        // productInfoArea에서 product 정보가 있다면 가져오기
        // 예시: loadChatHistory에서 sellerId, sellerAccountId를 전역변수로 보관
        if (window.lastProductInfo) {
            productSellerId = window.lastProductInfo.sellerId || productSellerId;
            productSellerAccountId = window.lastProductInfo.chatSellerAccountId || productSellerAccountId;
        }
    }

    // senderRole을 동적으로 설정
    const senderRole = (String(userId) === String(productSellerId)) ? "SELLER" : "BUYER";
    const chatSender = userId;
    console.log("send: chatSender: ", chatSender);

    // ★ productSellerId, buyerId 값이 undefined일 때 전역 값을 반드시 보완할 것
    const chatReceiver = (senderRole === "SELLER") ? buyerId : productSellerId;
    const chatReceiverAccountId = (senderRole === "SELLER") ? buyerAccountId : productSellerAccountId;

    console.log('send: chatReceiver: ', chatReceiver);

    // 방어 코드
    if (senderRole === "SELLER" && (!buyerId || !buyerAccountId)) {
        alert("구매자 정보가 없어 메시지 전송이 불가능합니다.");
        return;
    }
    if (senderRole === "BUYER" && !productSellerId) {
        alert("판매자 정보가 없어 메시지 전송이 불가능합니다.");
        return;
    }
    
    // ★ 여기! 현재 시간 넣기
    const chatCreatedAt = getCurrentChatTime();

    const chatMessage = {
        chatRoomId: currentRoomId,
        chatMessage: message,
        chatSenderAccountId: loginUserId,
        chatReceiverAccountId: chatReceiverAccountId,
        productId: productId,
        buyerId: buyerId,
        senderRole: senderRole,
        chatSender: chatSender,
        chatReceiver: chatReceiver,
        chatCreatedAt: chatCreatedAt // ★ 추가!
    };

    stompClient.send("/app/chat.send", {}, JSON.stringify(chatMessage));
    input.value = "";
}

function updateChatListLastMessage(roomId, chatMessage) {
	  // chatListRenderArea 안의 .chatList[data-room-id]에서 .chat-message를 찾아서 수정
	  var chatRenderArea = document.getElementById('chatListRenderArea');
	  if (!chatRenderArea) return;
	  var chatDiv = chatRenderArea.querySelector('.chatList[data-room-id="' + roomId + '"]');
	  if (chatDiv) {
	    var msgDiv = chatDiv.querySelector('.chat-message');
	    if (msgDiv) {
	      msgDiv.textContent = chatMessage;
	    }
	  }
	}



//뒤로가기 버튼 기능 추가
document.addEventListener('DOMContentLoaded', function() {
    const backBtn = document.getElementById('back-btn');
    if (backBtn) {
        backBtn.addEventListener('click', function() {
            window.history.back();
        });
    }
});


//window에 등록
window.highlightChatRoom = highlightChatRoom;
window.updateChatListLastMessage = updateChatListLastMessage;
</script>
</body>
</html>