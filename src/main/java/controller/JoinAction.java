package controller;

import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import model.dao.MemberDAO;
import model.dto.MemberDTO;

public class JoinAction implements Action {

	@Override
	public ActionForward execute(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		ActionForward forward = new ActionForward();
		request.setCharacterEncoding("UTF-8");
		
		String MID = request.getParameter("MID");
		String mName = request.getParameter("mName");
		
		// 비밀번호 체크하는 로직 -> View 담당
		String mPassword = request.getParameter("mPassword");
//		String mPassword2 = request.getParameter("mPassword2");
		
        // dob format: yyyy-MM-dd
		String year = request.getParameter("year");
		String month = request.getParameter("month");
		String day = request.getParameter("day");
		if (year.length() < 4) {
			while (year.length() < 4) {
				year += "0" + year;
			}
		} else if (year.length() > 4) {
			year.substring(0, 4);
		}
		if (month.length() == 1) {
			month += "0" + month;
		}
		if (day.length() == 1) {
			day += "0" + day;
		}
		
		String dateString = year + "-" + month + "-" + day;
        java.sql.Date sqlDate = null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date utilDate = sdf.parse(dateString);

            sqlDate = new java.sql.Date(utilDate.getTime());

        } catch (ParseException e) {
            e.printStackTrace();
        }
        
        String gender = request.getParameter("gender");
        // String 조합
        String phoneNumber = request.getParameter("phoneNum1") + "-" + request.getParameter("phoneNum2") + "-" + request.getParameter("phoneNum3");
		String email = request.getParameter("email1") + "@" + request.getParameter("email2");

		String zipNo = request.getParameter("zipNo");
		String roadAddrPart1 = request.getParameter("roadAddrPart1");
		String addrDetail = request.getParameter("addrDetail");
		// TODO: 나중에 분리해서 저장
		String addr = zipNo + "; " + roadAddrPart1 + "; " + addrDetail;
		
		String skel = request.getParameter("skel");
		String liver = request.getParameter("liver");
		String eye = request.getParameter("eye");
		String energy = request.getParameter("energy");
		String immune = request.getParameter("immune");
		String brain = request.getParameter("brain");
		String skin = request.getParameter("skin");
		String digest = request.getParameter("digest");
		String health = skel + "; " + liver + "; " + eye + "; " + energy + "; " + immune + "; " + brain + "; " + skin + "; " + digest;
		
		MemberDTO mDTO = new MemberDTO();
		MemberDAO mDAO = new MemberDAO();
		mDTO.setSearchCondition("회원가입");
		mDTO.setMid(MID);
		mDTO.setmName(mName);
		mDTO.setmPassword(mPassword);
		mDTO.setDob(sqlDate);
		mDTO.setGender(gender);
		mDTO.setPhoneNumber(phoneNumber);
		mDTO.setEmail(email);
		mDTO.setAddress(addr);
		mDTO.setHealth(health);
		
		if (mDAO.insert(mDTO)) {
			forward.setPath("mainPage.do");
			forward.setRedirect(false);
		} else {
			return null;
		}
		
		return forward;
	}

}
