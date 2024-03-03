<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quiz</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/quiz.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navfooter.css">
    
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
              <strong>Loged in successfully.</strong>
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
      e.printStackTrace();%>
      <div class="alertError">
        <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
        <strong>Warning !</strong> An error occurred. Please try again later..
      </div>
      <%;
      out.println("<script>alert('');</script>");
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
      response.sendRedirect("/Quiz"); // Redirect to the home page or any other appropriate page after logout
    }
  }
  %>
  
  
  <div class="nav-block">
      <h1>Quiz Competition</h1>
      <div class="nav">
          <a href="/Quiz" class="home">Home</a>
          <a href="/Quiz/nav/quiz.jsp" class="quiz">Quiz</a>
          <a href="/Quiz/nav/about.jsp" class="about">About</a>
          <a href="/Quiz/nav/contact.jsp" class="about">Contact</a>
          <% if (loggedInUser != null) { %>
          <a href="/Quiz/nav/profile.jsp" class="loginuser" id="profile" style="width: 200px; margin-left: 20px;">Welcome, <%= loggedInUser %>!</a>
          <form action=" " method="post">
              <input type="submit" class="logout" name="logout" id="userlogout" value="Logout">
          </form>
          <% } else { %>
          <button class="login" onclick="displayLogin()">Login</button>
          <button class="signup" onclick="displaySignup()">Signup</button>
          <% } %>
          <% if ("admin".equals(userRole)) { %>
          <a href="/Quiz/nav/admin_panel.jsp" class="loginuser" style="width: 160px; margin-left: 35px;">Admin Panel</a>
          <form action=" " method="post">
              <input type="submit" class="logout" name="logout" value="Logout">
          </form>
          <script>
              document.getElementById('profile').style.display = 'none';
              document.getElementById('userlogout').style.display = 'none';
          </script>
          <% } %>
      </div>
  </div>

    <div class="credentials">

          <div class="loginBox" id="login" style="display: none">

            <form class="credform" action=" " method="post">
              <span class="X" onclick="displayLogin()">X</span>
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

            </form>

          </div>

          <div class="signupBox" id="signup" style="display: none">
            <form class="credform" action=" " method="post" onsubmit="return validateForm()">
              <span class="X" onclick="displaySignup()">X</span>
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
            </form>

          </div>

    </div>
    <div class="block1">
        <div class="Box1">
          <h2>Low level</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/lowLevel.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/lowLevel.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/lowLevel.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/lowLevel.jsp">Quiz 4</a>
            </div>
          </div>
        </div>

        <div class="Box2">
          <h2>Intermediate level</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/interLevel.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/interLevel.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/interLevel.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/interLevel.jsp">Quiz 4</a>
            </div>
          </div>
        </div>

        <div class="Box3">
          <h2>High level</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/highLevel.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/highLevel.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/highLevel.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/highLevel.jsp">Quiz 4</a>
            </div>
          </div>
        </div>

      </div>

      <div class="block2">
        <div class="Box4">
          <h2>Polity</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/polity.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/polity.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/polity.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/polity.jsp">Quiz 4</a>
            </div>
          </div>
        </div>

        <div class="Box5">
          <h2>Economic</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/economics.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/economics.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/economics.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/economics.jsp">Quiz 4</a>
            </div>
          </div>
        </div>

        <div class="Box6">
          <h2>History</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/history.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/history.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/history.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/history.jsp">Quiz 4</a>
            </div>
          </div>

        </div>

        <div class="Box7">
          <h2>Geography</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/geography.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/geography.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/geography.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/geography.jsp">Quiz 4</a>
            </div>
          </div>

        </div>

        <div class="Box8">
          <h2>Science</h2>
          <div class="Quiz">
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/science.jsp">Quiz 1</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/science.jsp">Quiz 2</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/science.jsp">Quiz 3</a>
            </div>
            <div class="quie">
              <a href="<%= request.getContextPath() %>/Questions/science.jsp">Quiz 4</a>
            </div>
          </div>
        </div>
      </div>

      <footer>
        <div class="copyright">
          <p class="textCopyright"> &copy; Copyright</p>
        </div>
        <div class="social-media">
          <div class="imgcover">
            <a href="https://twitter.com" target="_blank"><img src="../img/twitter.webp" alt="Twitter" style="opacity: 0.6;"></a>
          </div>
        
          <div class="imgcover">
            <a href="https://instagram.com" target="_blank"><img src="../img/instagram.jpg" alt="Instagram"></a>
          </div>
        
          <div class="imgcover">
            <a href="https://facebook.com" target="_blank"><img src="../img/facebook.png" alt="Facebook" style="opacity: 0.6;"></a>
          </div>
        
          <div class="imgcover">
            <a href="https://linkedin.com" target="_blank"><img src="../img/linkedin.png" alt="LinkedIn"></a>
          </div>
        </div>
        
        
        <div class="textNav">
          <a href="/Quiz/nav/about.jsp" class="about">About</a> 
          <hr style="transform: rotate(180); margin: 0px 10px 0px 10px; ">
          <a href="/Quiz/nav/contact.jsp" class="about">Contact</a> 
          <hr style="transform: rotate(180); margin: 0px 10px 0px 10px; ">
          <a href="/Quiz/nav/quiz.jsp" class="quiz">Quiz</a> 
          <hr style="transform: rotate(180); margin: 0px 10px 0px 10px; ">
          <a href="/Quiz" class="home">Home</a> 
        </div>
        <div class="rahul" style="text-align: center; color: white; opacity: 0.5;">
          <p> &copy; Rahul Thorat</p>
        </div>
      </footer>

        <script>
          Login = document.getElementById('login');
          Signup = document.getElementById('signup');

          function displayLogin() {
            if (Login.style.display === 'none') {
              Login.style.display = 'block';
              Signup.style.display = 'none';
            }
            else {
              Login.style.display = 'none';
            }
          }

          function displayHide(){
            
            if (Signup.style.display === 'none') {
              Signup.style.display = 'block';
              Login.style.display = 'none';
            }
            else {
              Signup.style.display = 'none';
            }

          }

          function displaySignup() {

            if (Signup.style.display === 'none') {
              Signup.style.display = 'block';
              Login.style.display = 'none';
            }
            else {
              Signup.style.display = 'none';
            }

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