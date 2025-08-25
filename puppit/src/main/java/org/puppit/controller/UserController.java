package org.puppit.controller;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.puppit.model.dto.UserDTO;
import org.puppit.model.dto.UserStatusDTO;
import org.puppit.service.S3Service;
import org.puppit.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;

import lombok.RequiredArgsConstructor;

@RequestMapping("/user")
@RequiredArgsConstructor
@Controller
public class UserController {
  
  private final UserService userService;
  private final S3Service s3Service;
  private final AmazonS3 amazonS3;
  private static final String BUCKET = "jscode-upload-images";
  
  
  @SuppressWarnings("unchecked")
  @GetMapping("/mypage")
  public String myPage(HttpSession session, Model model) {
    Object attr = session.getAttribute("sessionMap");
    Map<String, Object> map = (Map<String, Object>)attr;
    Object accountId = map.get("accountId");
    String accountIdResult = accountId.toString();
    UserDTO userDTO = userService.getUserId(accountIdResult);
    model.addAttribute("user", userDTO);
    return "user/mypage";
  }
  
  // 회원가입 폼 보여주기
  @GetMapping("/signup")
  public String showSignupForm() {
      return "user/signup";  
  }

  @PostMapping("/signup")
  public String signUp(UserDTO user, RedirectAttributes redirectAttr) {
    // 회원가입
    boolean signupResult = userService.signup(user);
    // 회원가입 실패
    if(!signupResult) {
      redirectAttr.addFlashAttribute("error", "아이디를 입력 해주세요");
      return "redirect:/user/signup";
    }
    // 회원가입 성공
    redirectAttr.addFlashAttribute("msg", "Puppit에 오신것을 환영 합니다");
    return "redirect:/";
  }
  
  // 중복 검사
  @GetMapping("/check")
  public ResponseEntity<Void> check(UserDTO userDTO) {
    if(userDTO.getNickName() != null && userService.isNickNameAvailable(userDTO.getNickName())) {
      return ResponseEntity.ok().build();
    } else if(userDTO.getAccountId() != null && userService.isAccountIdAvailable(userDTO.getAccountId())) {
      return ResponseEntity.ok().build();
    } else if(userDTO.getUserEmail() != null && userService.isUserEmailAvailable(userDTO.getUserEmail())) {
      return ResponseEntity.ok().build();
    } else {
      return ResponseEntity.status(HttpStatus.CONFLICT).build();
    }
  }
  
  // 로그인 폼 보여주기
  @GetMapping("/login")
  public String loginForm() {
    return "user/login";
  }
  
  @PostMapping("/login")
  public String login(UserDTO user, HttpSession session, RedirectAttributes redirectAttr, HttpServletRequest request) {
    try {
      UserDTO loginResult = userService.login(user);

      if (loginResult == null) {
          // 실패: 아이디나 비밀번호가 틀림
          redirectAttr.addFlashAttribute("error", "아이디나 비밀번호를 확인 해주세요");
          return "redirect:/user/login";
      }
      
      HttpSession oldSession = request.getSession(false);
      if(oldSession != null) {
       oldSession.invalidate(); 
      }
      // 성공: 세션 저장 (db에서 가져온 loginResult 사용)
      Map<String, Object> sessionMap = new HashMap<String, Object>();
      sessionMap.put("userId", loginResult.getUserId());
      sessionMap.put("accountId", loginResult.getAccountId());
      sessionMap.put("userName", loginResult.getUserName());
      sessionMap.put("nickName", loginResult.getNickName());
      sessionMap.put("userEmail", loginResult.getUserEmail());
      
      session = request.getSession(true);
      session.setAttribute("sessionMap", sessionMap);
      
      // timeStamp 생성
      Date now = new Date();
      SimpleDateFormat stf = new SimpleDateFormat("yyyy/MM/dd HH:mm");
      String dateTimeStr = stf.format(now);
      Date date = stf.parse(dateTimeStr);
      Timestamp timestamp = new Timestamp(date.getTime());

      UserStatusDTO userLog = new UserStatusDTO(loginResult.getAccountId(), loginResult.getUserId(), timestamp);
      userService.insertLogStatus(userLog);

      redirectAttr.addFlashAttribute("msg", "로그인 성공!");
      return "redirect:/";
  } catch (Exception e) {
     e.printStackTrace();
     redirectAttr.addFlashAttribute("error", "로그인 중 오류가 발생했습니다.");
     return "redirect:/user/login";
  }
}
   // 로그 아웃
  @GetMapping("/logout")
  public String logout(HttpSession session) {
    session.invalidate();
    return "redirect:/";
  }
  // 아이디 찾기 JSP
  @GetMapping("/find")
  public String findCheckForm() {
    return "user/find";
  }
  // 아이디 찾기
  @PostMapping("/find")
  public String findCheck(RedirectAttributes redirectAttr, UserDTO user) {
    String findId = userService.findAccountIdByUserNameUserEmail(user);
    if(findId == null) {
      redirectAttr.addFlashAttribute("msg", "입력하신 정보로 가입 된 회원 아이디는 존재하지 않습니다.");
      return "redirect:/user/find";
    } else {
      redirectAttr.addFlashAttribute("msg", findId + "입니다.");
      return "redirect:/user/login";
    }
  }
  // mypage에서 profile 가기전 password 검사
  @GetMapping("/checkPassword")
  public String checkPwd() {
    return "user/checkPassword";
  }
  @PostMapping("/checkPassword")
  public String checkPwd(RedirectAttributes redirectAttr, 
                         @SessionAttribute(name = "sessionMap", required = false) Map<String, Object> sessionMap, 
                         @RequestParam("userPassword") String userPassword) {
    try {
      if(sessionMap == null || sessionMap.get("userId") == null) {
        redirectAttr.addFlashAttribute("msg", "로그인이 필요합니다");
        return "redirect:/user/login";
      }

      Integer userId = (Integer) sessionMap.get("userId"); // <-- 키는 "userId"

      boolean ok = userService.passwordCheck(userId, userPassword);
      if (!ok) {
        redirectAttr.addFlashAttribute("msg", "비밀번호가 일치하지 않습니다");
        return "redirect:/user/checkPassword";
      }
      return "redirect:/user/profile";
    } catch (Exception e) {
      e.printStackTrace();
      redirectAttr.addFlashAttribute("error", "오류가 발생 했습니다");
      return "redirect:/user/mypage";
    }
  }

  @GetMapping("/profile")
  public String profileForm() {
    return "user/profile";
  }
  // 프로필 페이지
  @PostMapping("/profile")
  public String profileEdit(RedirectAttributes rttr,
                            HttpSession session,
                            HttpServletRequest request,
                            @RequestParam("accountId") String accountId,
                            @RequestParam("userName") String userName,
                            @RequestParam("nickName") String nickName,
                            @RequestParam("userEmail") String userEmail) {
    
    @SuppressWarnings("unchecked")
    Map sessionMap = (Map<String, Object>)session.getAttribute("sessionMap");
    String prevAccountId = (String) sessionMap.get("accountId");
    UserDTO user = userService.getUserId(prevAccountId);
    user.setAccountId(accountId);
    user.setUserName(userName);
    user.setNickName(nickName);
    user.setUserEmail(userEmail);
    Map<String, Object> map = new HashMap<>();
    map.put("user", user);
    map.put("prevAccountId", prevAccountId);
    boolean result = userService.updateUser(map);
    
    rttr.addFlashAttribute("msg", result ? "프로필 수정 성공" : "프로필 수정 실패");
    
    UserDTO newUser = userService.getUserId(accountId);
    
    Map<String, Object> newSessionMap = new HashMap<String, Object>();
    newSessionMap.put("userId", newUser.getUserId());
    newSessionMap.put("accountId", newUser.getAccountId());
    newSessionMap.put("userName", newUser.getUserName());
    newSessionMap.put("nickName", newUser.getNickName());
    newSessionMap.put("userEmail", newUser.getUserEmail());
    
    session = request.getSession(true);
    session.setAttribute("sessionMap", newSessionMap);
    
    return "redirect:/";
  }
  
  @PostMapping("/profile/image")
  public String changeProfileimage(@SessionAttribute("sessionMap") Map<String, Object> sessionMap,
                                   @RequestParam("file") MultipartFile file,
                                   RedirectAttributes rttr) {
    
    Integer userId = (Integer) sessionMap.get("userId");
    if(userId == null) return "redirect:/login";
    try {
      // ex) "profile/123"
      String folder = "profile/" + userId;
      Map<String, String> uploaded = s3Service.uploadFile(file, folder);
      String newKey = uploaded.get("fileName"); // ex) profile/123/uuid_filename.jpg
      
      // 기존 키 조회 후 삭제(옵션)
      String oldKey = userService.getProfileImageKey(userId).getProfileImageKey();
      if (oldKey != null && !oldKey.isBlank()) {
          try {
              amazonS3.deleteObject(BUCKET, oldKey);
              // 필요 시만 삭제
              // amazonS3.deleteObject(bucket, oldKey);
          } catch (Exception ignore) {}
      }

      // DB에 새 키 저장 (URL 말고 Key를 저장하세요)
      userService.updateProfileImageKey(userId, newKey);

      rttr.addFlashAttribute("msg", "프로필 이미지가 변경되었습니다.");
      amazonS3.setObjectAcl("jscode-upload-images", newKey, CannedAccessControlList.PublicRead);
    } catch (Exception e) {
      rttr.addFlashAttribute("msg", "업로드 실패" + e.getMessage());
    }
    
    return "redirect:/user/mypage";                                   
  }
}
