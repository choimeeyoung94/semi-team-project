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
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="loginUserId" value="<%= accountId %>" />
<c:set var="userId" value="<%=userId %>"/>
<c:set var="highlightRoomIdStr" value="${highlightRoomIdStr}"/>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 목록</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        body { font-family: 'Noto Sans KR', sans-serif; background: #fff; margin: 0; padding: 0; }
        .container-header { text-align: center; margin-top: 40px; margin-bottom: 24px; }
        .container-header h1 { font-size: 24px; font-weight: bold; letter-spacing: -1px; color: #222; }
        .container { width: 1000px; min-height: 700px; display: flex; flex-direction: row; gap: 20px; justify-content: center; align-items: flex-start; margin: 0 auto; background: #fff; }
        .chatlist-container { width: 400px; height: 600px; border: none; padding: 0; margin: 0; overflow-y: auto; }
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
        .chat-container { width: 400px; height: 600px; display: flex; flex-direction: column; justify-content: flex-end; padding: 20px; box-sizing: border-box; background: #fafafa; }
        .chat-input-group { display: flex; flex-direction: row; gap: 8px; width: 100%; }
        .chat-container input { min-width: 0; padding: 0 10px; font-size: 16px; height: 38px; border: 1px solid #ccc; border-radius: 8px; background: #fff; box-sizing: border-box; }
        .chat-container button { height: 38px; padding: 0 24px; font-size: 16px; border: none; border-radius: 8px; background: #888; color: #fff; cursor: pointer; box-sizing: border-box; margin-top: 10px; }
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
    </style>
</head>
<body>
<div class="container-header">
    <h1>채팅방 목록</h1>
</div>
<div class="container">
    <div class="chatlist-container" id="chatlist-container">
        <div id="chatListRenderArea">
            <c:forEach items="${chatList}" var="chat">
                <div class="chatList" data-room-id="${chat.roomId}">
                    <span class="chat-profile-img chat-profile-icon">
                        <i class="fa-solid fa-user"></i>
                    </span>
                    <div class="chat-info-area" style="cursor:pointer;">
                        <div class="chat-nickname">
                            <c:choose>
                                <c:when test="${not empty chat.lastMessage}">
                                    <c:out value="${chat.lastMessageSenderName}" />
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${chat.productName}" /> (<c:out value="${chat.sellerName}" />)
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
            <input placeholder="채팅메시지를 입력하세요"/>
            <button type="submit">전송</button>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.2/stomp.min.js"></script>
<script>
const contextPath = "${contextPath}";
const loginUserId = "${loginUserId}";
const userId = "${userId}";

const centerMessage = document.getElementById('center-message');
const chatHistory = document.getElementById('chat-history');
const productInfoArea = document.getElementById('product-info-area');

let stompClient = null;
let currentRoomId = null;
let currentSubscription = null;
let isConnected = false;
let productId = null;
let buyerId = null;

document.addEventListener('DOMContentLoaded', function() {
    const chatlist = document.getElementById('chatlist-container');
    chatlist.addEventListener('click', function(e) {
        const chatDiv = e.target.closest('.chatList');
        if (chatDiv) {
            const roomId = chatDiv.dataset.roomId;
            currentRoomId = roomId;
            if (roomId) {
                loadChatHistory(roomId).then(() => {
                    connectAndSubscribe(roomId);
                });
            }
        }
    });

    const sendBtn = document.querySelector('button[type="submit"]');
    if (sendBtn) {
        sendBtn.addEventListener('click', function(e){
            e.preventDefault();
            sendMessage(currentRoomId);
        });
    }
    enableChatInput(false);
});

function loadChatHistory(roomId) {
    return fetch(contextPath + '/chat/message?roomId=' + roomId)
        .then(response => response.json())
        .then(data => {
            if (data.product) {
                renderProductInfo(data.product, data.chatMessages || []);
            } else {
                productInfoArea.innerHTML = '';
            }
            chatHistory.innerHTML = "";
            const messages = Array.isArray(data.chatMessages) ? data.chatMessages : [];
            messages.forEach(chat => addChatMessageToHistory(chat));

            // 🔥 메시지가 있으면 안내 문구 숨기기
            if (messages.length > 0) {
                centerMessage.style.display = "none";
            } else {
                centerMessage.style.display = "block";
            }
        });
}

function renderProductInfo(product, chatMessages) {
    const price = Number(product.productPrice);
    let html =
        '<div style="margin-bottom:10px; border-bottom:1px solid #eee; padding-bottom:12px;">'
        + '<strong>상품명:</strong> ' + product.productName + '<br>'
        + '<strong>가격:</strong> ' + (isNaN(price) ? product.productPrice : price.toLocaleString()) + '원 <br>';

    // 🔥 로그인된 사용자와 판매자가 다른 경우 결제 버튼 추가
    if (String(userId) !== String(product.sellerId)) {
        html += `<button
            id="pay-btn"
            	data-buyer-id="\${resolvedBuyerId}"
                    data-seller-id="\${product.sellerId}"
                    data-seller-account-id="\${chatSellerAccountId}"
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
            console.log(btn);
            console.log(btn.dataset)
            // 반드시 data-seller-account-id를 읽어서 콘솔에 찍음!
            chatSellerAccountId =  btn.dataset.sellerAccountId;
            console.log('결제버튼 클릭 - chatSellerAccountId:', chatSellerAccountId); // 여기서 찍힘
            quantity = 1;
            productId = product.productId;
            buyerId = resolvedBuyerId;
            var payUrl = contextPath + '/order/pay'
                + '?buyerId=' + encodeURIComponent(resolvedBuyerId)
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
    let alignClass = (chat.senderRole === "BUYER") ? "right" : "left";
    let msg = chat.message || chat.chatMessage || "";
    let formattedTime = chat.chatCreatedAt || "";
    let html =
        '<div class="chat-message ' + alignClass + '">' +
            '<div class="chat-userid">' + (chat.chatSenderAccountId || "") + '</div>' +
            '<div class="chat-text">' + msg + '</div>' +
            '<div class="chat-time">' + formattedTime + '</div>' +
        '</div>';
    chatHistory.innerHTML += html;
    chatHistory.scrollTop = chatHistory.scrollHeight;
}

function connectAndSubscribe(currentRoomId) {
    if (!stompClient) {
        const socket = new SockJS(contextPath + '/ws-chat');
        stompClient = Stomp.over(socket);
        stompClient.connect({}, function() {
            isConnected = true;
            subscribeRoom(currentRoomId);
            enableChatInput(true);
        });
    } else {
        subscribeRoom(currentRoomId);
        enableChatInput(isConnected);
    }
}

function subscribeRoom(currentRoomId) {
    if (currentSubscription) currentSubscription.unsubscribe();
    currentSubscription = stompClient.subscribe('/topic/chat/' + currentRoomId, function(msg) {
        const chat = JSON.parse(msg.body);
        addChatMessageToHistory(chat);
        // 새 메시지가 오면 안내 문구 숨김
        centerMessage.style.display = "none";
    });
}

function enableChatInput(enable) {
    const input = document.querySelector('input[placeholder="채팅메시지를 입력하세요"]');
    const button = document.querySelector('button[type="submit"]');
    if (input && button) {
        input.disabled = !enable;
        button.disabled = !enable;
    }
}

function sendMessage(currentRoomId) {
    if (!stompClient || !isConnected) return;
    const input = document.querySelector('input[placeholder="채팅메시지를 입력하세요"]');
    const message = input.value;
    if (!message.trim() || !currentRoomId) return;
    stompClient.send("/app/chat.send", {}, JSON.stringify({
        chatRoomId: currentRoomId,
        chatMessage: message,
        chatSenderAccountId: loginUserId,
        productId: productId,
        buyerId: buyerId
    }));
    input.value = "";
}
</script>
</body>
</html>