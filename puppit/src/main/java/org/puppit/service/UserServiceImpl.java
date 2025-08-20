package org.puppit.service;

import java.util.Map;

import org.puppit.model.dto.ChatUserDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.puppit.repository.UserDAO;
import org.puppit.util.SecureUtil;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class UserServiceImpl implements UserService {
  
  private final UserDAO userDAO;
  private final SecureUtil secureUtil;
  
  private boolean emptyCheck(String... fields) {
    for(String field : fields) {
      if(field == null || field.trim().isEmpty()) {
        return true;
      }
    }
    return false; 
  }

  public boolean signup(UserDTO user) {
    try {
      // salt 생성
      byte[] salt = secureUtil.getSalt();
      // 비밀번호 암호화 하기
      String encryptedPassword = secureUtil.hashPBKDF2(user.getUserPassword(), salt);
      // DB로 보낼 salt, 암호화 된 비밀번호를 UserDTO에 저장
      user.setSalt(salt);
      user.setUserPassword(encryptedPassword);
      if(emptyCheck(user.getAccountId(), user.getUserPassword(), user.getUserName(), user.getNickName(), user.getUserEmail(), user.getUserPhone())) {
        return false;
      }
      return userDAO.userSignUp(user) == 1 ? true : false;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  @Override
  public UserDTO login(UserDTO user) {
    try {
      // 빈값 체크
      if (emptyCheck(user.getAccountId(), user.getUserPassword())) {
        return null;
      }
      
      // 1) DB에서 accountId로 사용자 정보(솔트, 저장된 해시) 가져오기
      UserDTO dbUser = userDAO.getUserByaccountId(user.getAccountId());
      if (dbUser == null) {
        return null; // 계정 없음
      }
      
      // 2) 솔트 꺼내기 (DB에 VARBINARY로 저장되어 있으면 byte[]로 매핑됨)
      byte[] salt = dbUser.getSalt();
      if (salt == null) {
        return null; // 안전장치
      }
      
      // 3) 클라이언트가 보낸 평문 비밀번호를 PBKDF2로 해시화
      // secureUtil.hashPBKDF2(...)는 byte[] -> hex(String) 또는 byte[] 반환 등
      // 아래는 "hex 문자열" 반환 가정
      String Password = user.getUserPassword();
      String encryptedPassword = secureUtil.hashPBKDF2(Password, salt); // returns hex string
      
      // 4) DB에 저장된 해시와 안전비교
      String storedHash = dbUser.getUserPassword(); // DB에 저장된 해시 (hex)
      if (storedHash == null) return null;
      
      return encryptedPassword.equals(dbUser.getUserPassword()) ? dbUser : null;
      
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }
  // 아이디 찾기
  @Override
  public String findAccountIdByUserNameUserEmail(UserDTO user) {
    return userDAO.findAccountIdByNameAndEmail(user);
  }
  @Override
  public Boolean isAccountIdAvailable(String accountId) {
    return userDAO.countByAccountId(accountId.trim().toLowerCase()) == 0; 
  } 
  @Override
  public Boolean isNickNameAvailable(String nickName) {
    return userDAO.countByNickName(nickName.trim()) == 0;
  }
  @Override
  public Boolean isUserEmailAvailable(String userEmail) {
    return userDAO.countByEmail(userEmail.trim().toLowerCase()) == 0;
  }
  @Override
  public Integer insertLogStatus(UserStatusDTO log) {
    return userDAO.insertLogStatus(log);
  }
  @Override
  public UserDTO getUserId(String accountId) {
    return userDAO.getUserId(accountId);
  }

  // 채팅 보낸 사람의 사용자 정보 조회
  @Override
  public ChatUserDTO getUserByUserId(String senderUserId) {
	return userDAO.getUserByUserId(senderUserId);
  }

  @Override
  public boolean updateUser(Map<String, Object> map) {
    return userDAO.updateUser(map) == 1;
   
  }

}


