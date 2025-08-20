package org.puppit.repository;

import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.puppit.model.dto.ChatUserDTO;
import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Repository
public class UserDAO {
  
  private final SqlSessionTemplate sqlSession;
  
  public Integer userSignUp(UserDTO user) {
    return sqlSession.insert("mybatis.mapper.userMapper.userSignUp", user);
  }
  public Integer countByAccountId(String accountId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.countByAccountId", accountId);
  }
  public Integer countByNickName(String nickName) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.countByNickName", nickName);
  }
  public Integer countByEmail(String userEmail) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.countByEmail", userEmail);
  }
  public String getUserById(String userId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserById", userId);
  }
  public UserDTO getUserByaccountId(String accountId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserByaccountId", accountId);
  }
  public Integer insertLogStatus(UserStatusDTO log) {
    return sqlSession.insert("mybatis.mapper.userMapper.insertLogStatus", log);
  }
  public UserDTO getUserId(String accountId) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserId", accountId);
  }
  public String findAccountIdByNameAndEmail(UserDTO user) {
    return sqlSession.selectOne("mybatis.mapper.userMapper.findAccountIdByNameAndEmail", user);
  }
  
  //채팅 보낸 사람의 사용자 정보 조회
  public ChatUserDTO getUserByUserId(String senderUserId) {

    return sqlSession.selectOne("mybatis.mapper.userMapper.getUserByUserId", senderUserId);


 
  }
  
  public Integer updateUser(Map<String, Object> map) {
    return sqlSession.update("mybatis.mapper.userMapper.updateUser", map);
  }
  

}