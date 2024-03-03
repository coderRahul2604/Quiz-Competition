<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Credential Page</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/cred.css">
</head>

<body>
  <%@ page contentType="text/html;charset=UTF-8" %>
  <%@ page import="java.sql.*" %>
  <%@ page import="javax.servlet.http.HttpSession" %>
  
  <%
  Connection con = null;
  PreparedStatement pst = null;
  ResultSet rs = null;
  
  
  try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      con = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");
  
      if (request.getParameter("signup") != null) {
          String username = request.getParameter("username");
          String password = request.getParameter("password");
          String admin = request.getParameter("admin");
  
          String sql = "INSERT INTO credentials (username, password, admin) VALUES (?, ?, ?)";
          pst = con.prepareStatement(sql);
          pst.setString(1, username);
          pst.setString(2, password);
          pst.setString(3, admin);
  
          int rowsAffected = pst.executeUpdate();
  
          if (rowsAffected > 0) {
            %>
            <div class="alertSuccess">
              <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
              <strong>Sign-up in successfully.</strong>
            </div>
            <%
          } else {
            %>
              <div class="alertError">
                <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                Something went wrong. Please try again.
              </div>
              <%;
          }
      }
  
      if (request.getParameter("login") != null) {
          String username = request.getParameter("username");
          String password = request.getParameter("password");
  
          String sql = "SELECT * FROM credentials WHERE username=? AND password=?";
          pst = con.prepareStatement(sql);
          pst.setString(1, username);
          pst.setString(2, password);
  
          rs = pst.executeQuery();
  
          if (rs.next()) {
              session.setAttribute("loggedInUser", username);
              String userRole = rs.getString("admin");
              session.setAttribute("admin", userRole);
              response.sendRedirect("/Quiz/nav/quiz.jsp");
              %>
              <div class="alertSuccess">
                <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                <strong>Loged in successfully.</strong>
              </div>
              <%
          } else {
            %>
              <div class="alertError">
                <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                <strong>Warning !</strong> Invalid username or password.
              </div>
              <%;
          }
      }
  } catch (Exception e) {
      e.printStackTrace();
      out.println("<script>alert('An error occurred. Please try again later.');</script>");
  } finally {
      try {
          if (rs != null) {
              rs.close();
          }
          if (pst != null) {
              pst.close();
          }
          if (con != null) {
              con.close();
          }
      } catch (SQLException e) {
          e.printStackTrace();
      }
  }
  String loggedInUser = (String) session.getAttribute("loggedInUser");
  String userRole = (String) session.getAttribute("admin");
  if (request.getParameter("logout") != null) {
    if (session != null && loggedInUser != null) {
      session.invalidate();
      response.sendRedirect("/Quiz");
    }
  }
  %>
  

    <div class="credentials">

          <div class="loginBox" id="login">

            <form class="credform" action=" " method="post">
              <h2 class="credHead">Login</h2>
              <label for="username">Username</label>
              <br>
              <input type="text" name="username" id="loginuser" placeholder="Enter user name" required>
              <br>
              <label for="password">Password</label>
              <br>
              <input type="password" name="password" id="loginpass" placeholder="Enter password" required>
              <br>
              <input type="submit" class="credbtn" name="login" id="loginbtn" value="Login">

              <input type="button" class="newAccount" value="New regisitration ?" onclick="showFunc()">

            </form>

          </div>

          <div class="signupBox" id="signup" style="display: none;">
            <form class="credform" action=" " method="post" onsubmit="return validateForm()">
              <h2 class="credHead">Sign-up</h2>
              <label for="username">Username</label>
              <br>
              <input type="text" name="username" id="Signuser" placeholder="Enter username" required>
              <br>
              <label for="password">Password</label>
              <br>
              <input type="password" name="password" id="Signpass1" placeholder="Enter password" required>
              <br>
              <label for="password1">Password again</label>
              <br>
              <input type="password" name="password1" id="Signpass2" placeholder="Enter password again" required>
              <br>
              <input type="hidden" id="admin" name="admin" >
              
              <input type="submit" class="credbtn" name="signup" id="sign-upbtn" value="Sign-up">

              <input type="button" class="newAccount" value="Go back to login" onclick="hideSignup()">
            </form>

          </div>

    </div>

        <script>
          Login = document.getElementById('login');
          Signup = document.getElementById('signup');

          function showFunc(){
            Login.style.display="none";
            Signup.style.display="block";
          }
          function hideSignup(){
            Login.style.display="block";
            Signup.style.display="none";
          }

          function validateForm() {
            var password1 = document.getElementById("Signpass1").value;
            var password2 = document.getElementById("Signpass2").value;

            if (password1 !== password2) {
                alert("Passwords do not match. Please re-enter your password.");
                return false;
            }
            return true; 
    }
          

        </script>
</body>
</html>