<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Panel</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navfooter.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin_panel.css">
   
</head>

<body>
  <%@ page contentType="text/html;charset=UTF-8" %>
  <%@ page import="java.sql.*" %>
  <%@ page import="javax.servlet.http.HttpSession" %>
  
  <%
  
  Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
  
    if (request.getParameter("submit") != null) {
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");
        String question_type = request.getParameter("question_type");
        String question_level = request.getParameter("question_level");

        try {
            
            Class.forName("com.mysql.cj.jdbc.Driver");

            
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");

            
            String sql = "INSERT INTO questions (question_text, option_a, option_b, option_c, option_d, correct_option, question_type, question_level) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

          
            pst = con.prepareStatement(sql);

           
            pst.setString(1, questionText);
            pst.setString(2, optionA);
            pst.setString(3, optionB);
            pst.setString(4, optionC);
            pst.setString(5, optionD);
            pst.setString(6, correctOption);
            pst.setString(7, question_type);
            pst.setString(8, question_level);

            
            int rowsAffected = pst.executeUpdate();

            if (rowsAffected > 0) {
                %>
                <div class="alertSuccess">
                  <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                  <strong>Question added successfully.</strong>
                </div>
                <%
            } else {
                %>
                <div class="alertError">
                  <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                  Failed to add question. Please try again.
                </div>
                <%;
            }
        } 
        catch (SQLException e) {
            e.printStackTrace();
            %>
                <div class="alertError">
                  <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                  Failed to add question. Please try again.
                </div>
                <%
        } 
        catch (ClassNotFoundException e) {
         e.printStackTrace();

         %>
                <div class="alertError">
                  <span class="closebtn" onclick="this.parentElement.style.display='none';">&times;</span> 
                  Failed to add question. Please try again.
                </div>
                <%
     } 
        finally {
  
            try {
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
    }

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
      } catch (ClassNotFoundException cnfe) {
        cnfe.printStackTrace();
        out.println("<script>alert('Database driver not found.');</script>");
      }  finally {
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
      if (loggedInUser != null) {
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

        <div class="addque">
            <button onclick="openNewPage()">Add Question</button>
            <button onclick="openUserDetail()">User Details</button>
            <button onclick="openAddedQue()">Added Questions</button>
            <button onclick="openFeedback()">Feedbacks </button>
            <button onclick="openReport()">Report Generation</button>
        </div>

        <div class="floatRightDiv">

            <div class="welcomeDiv" id="welcomeDiv">
                <h2>Welcome Admin </h2>
            
            </div>

        
            <div class="addingquetionsdiv" id="addingquetionsdiv" style="display: none;">
                <h2>Add Quiz Question</h2>
                <form action=" " method="post">
                    <label for="questionText">Question:</label>
                    <br><br>
                    <textarea id="questionText" placeholder="Write Question Here...." name="questionText" rows="4" cols="50"
                        required></textarea>
                    <br>
                
                    <label for="question_type">Question Type:</label>
                    <select name="question_type" id="question_type" class="Select question Subject(type)" required>
                        <option value="" disabled selected>Select a question type...</option>
                        <option value="polity">Polity</option>
                        <option value="economics">Economics</option>
                        <option value="history">History</option>
                        <option value="geography">Geography</option>
                        <option value="science">Science</option>
                    </select>
                    <br><br>
                    
                    <label for="question_level">Question Level:</label>
                    <br><br>
                    <select name="question_level" id="question_level" class="Select question difficulty" required>
                        <option value="" disabled selected>Select a question level...</option>
                        <option value="low">Low</option>
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                    </select>
                    <br><br>
                
                    <label for="optionA">Option A:</label>
                    <br><br>
                    <input type="text" id="optionA" name="optionA" placeholder="Option A" required>
                    <input type="radio" id="correctOptionA" name="correctOption" value="A">
                    <label for="correctOptionA">Correct Answer</label>
                    <br><br>
                
                    <label for="optionB">Option B:</label>
                    <br><br>
                    <input type="text" id="optionB" name="optionB" placeholder="Option B" required>
                    <input type="radio" id="correctOptionB" name="correctOption" value="B">
                    <label for="correctOptionB">Correct Answer</label>
                    <br><br>
                
                    <label for="optionC">Option C:</label>
                    <br><br>
                    <input type="text" id="optionC" name="optionC" placeholder="Option C" required>
                    <input type="radio" id="correctOptionC" name="correctOption" value="C">
                    <label for="correctOptionC">Correct Answer</label>
                    <br><br>
                
                    <label for="optionD">Option D:</label>
                    <br><br>
                    <input type="text" id="optionD" name="optionD" placeholder="Option D" required>
                    <input type="radio" id="correctOptionD" name="correctOption" value="D">
                    <label for="correctOptionD">Correct Answer</label>
                    <br><br>

                    <input type="submit" name="submit" value="Add Question" style="background-color: #4CAF50;">
                </form>

            </div>

            <div class="UserDetailDiv" id="UserDetailDiv" style="display: none;">
                <h2>User Details</h2>
                <table>
                    <tr>
                        <th>Username</th>
                        <th>Password</th>
                        <th>Admin Status</th>
                    </tr>
                <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");
                
                    PreparedStatement statement = connection.prepareStatement("SELECT * FROM credentials");
                    ResultSet resultSet = statement.executeQuery();

                    while(resultSet.next()) {
                        String username = resultSet.getString("username");
                        String password = resultSet.getString("password");
                        String isAdmin = resultSet.getString("admin");
                %>
                    <tr>
                        <td><%= username %></td>
                        <td><%= password %></td>
                        <td><%= isAdmin %></td>
                    </tr>
                    <%
                }
                resultSet.close();
                statement.close();
                connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            %>
        </table>
            </div>
        
            <div class="AddedQueDiv" id="AddedQueDiv" style="display: none;">
                <h2>Added Questions</h2>
                <table>
                    <th>Question ID</th>
                    <th>Question Title</th>
                    <th>Correct Type</th>
                    <th>Correct Level</th>
                    <th>Correct Answer Option</th>
                    <th>Option A</th>
                    <th>Option B</th>
                    <th>Option C</th>
                    <th>Option D</th>
                <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");
                
                    PreparedStatement statement = connection.prepareStatement("SELECT * FROM questions");
                    ResultSet resultSet = statement.executeQuery();

                    while(resultSet.next()) {
                        String questionID = resultSet.getString("question_id");
                        String questionText = resultSet.getString("question_text");
                        String optionA = resultSet.getString("option_a");
                        String optionB = resultSet.getString("option_b");
                        String optionC = resultSet.getString("option_c");
                        String optionD = resultSet.getString("option_d");
                        String correctOption = resultSet.getString("correct_option");
                        String questionType = resultSet.getString("question_type");
                        String questionLevel = resultSet.getString("question_level");
                    %>
                    <tr>
                        <td> <%= questionID %> </td>
                        <td> <%= questionText %> </td>
                        <td> <%= questionType %> </td>
                        <td> <%= questionLevel %> </td>
                        <td> <%= correctOption %> </td>
                        <td> <%= optionA %> </td>
                        <td> <%= optionB %> </td>
                        <td> <%= optionC %> </td>
                        <td> <%= optionD %> </td>
                    </tr>
                    <% 
                    }
                    resultSet.close();
                    statement.close();
                    connection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                %>

                </table>
            </div>

            <div class="FeedbackDiv" id="FeedbackDiv" style="display: none;">
                    <h2>Feedback Details</h2>
                <table>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Message</th>
                    </tr>
                <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");
                
                    PreparedStatement statement = connection.prepareStatement("SELECT * FROM feedback");
                    ResultSet resultSet = statement.executeQuery();

                    while(resultSet.next()) {
                        String name = resultSet.getString("name");
                        String email = resultSet.getString("email");
                        String message = resultSet.getString("message");
                %>
                    <tr>
                        <td><%= name %></td>
                        <td><%= email %></td>
                        <td><%= message %></td>
                    </tr>
                    <%
                }
                resultSet.close();
                statement.close();
                connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            %>
                </table>
            </div>


            <div class="ReportsDiv" id="ReportsDiv" style="display: none;">
                <h2>Report Generation</h2>
            
                <div class="report">
                    <form method="post" action=" ">
                        <input type="date" name="startDate" placeholder="Starting Date" required>
                        <input type="date" name="endDate" placeholder="Ending Date" required>
                    
                        <input type="submit" name="UserReport" value="User Report">
                    </form>
                    <%
                    if (request.getParameter("UserReport") != null) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");
                
                    String startDate = request.getParameter("startDate");
                    String endDate = request.getParameter("endDate");

                    String userDataQuery = "SELECT * FROM credentials WHERE `Date&Time` BETWEEN ? AND ?";

                    pst = con.prepareStatement(userDataQuery);
                    pst.setString(1, startDate);
                    pst.setString(2, endDate);
                
                    rs = pst.executeQuery();
            %>
                    <div class="displayUserReport" id="displayUserReport">
                        <h1>User Report</h1>
                        <table class="reportTable">
                            <tr>
                                <th>Username</th>
                                <th>Password</th>
                                <th>Date</th>
                            </tr>
                            <%
                            while (rs.next()) {
                                String username = rs.getString("username");
                                String password = rs.getString("password");
                                String date = rs.getString("Date&Time");
                            %>
                                <tr>
                                    <td><%= username %></td>
                                    <td><%= password %></td>
                                    <td><%= date %></td>
                                </tr>
                            <%
                            }
                            %>
                        </table>
                        <input type="button"id="CloseUserReport" value="Close" onclick="CloseUserReport()">
                    </div>
            <%
                } catch (Exception e) {
                    e.printStackTrace();
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
            }
            %>

                </div>
            
                <div class="report">
                    <form method="post" action=" ">
                        <input type="date" name="startDate" placeholder="Starting Date" required>
                        <input type="date" name="endDate" placeholder="Ending Date" required>
                    
                        <input type="submit" name="questionReport" value="Question Report">
                    </form>
                    <%
                    if (request.getParameter("questionReport") != null) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");
                        
                        String startDate = request.getParameter("startDate");
                        String endDate = request.getParameter("endDate");

                        String userDataQuery = "SELECT * FROM questions WHERE `Date&Time` BETWEEN ? AND ?";

                        pst = con.prepareStatement(userDataQuery);
                        pst.setString(1, startDate);
                        pst.setString(2, endDate);
                        
                        rs = pst.executeQuery();
                    %>
                    <div class="displayQuestionReport" id="displayQuestionReport">
                        
                        <h1>Question Report</h1>
                        <table class="reportTable">
                            <tr>
                                <th>SR.NO</th>
                                <th>Question</th>
                                <th>Subject</th>
                                <th>Level</th>
                                <th>Date</th>
                            </tr>
                            <%
                            while (rs.next()) {
                                String question_id = rs.getString("question_id");
                                String question_text = rs.getString("question_text");
                                String question_type = rs.getString("question_type");
                                String question_level = rs.getString("question_level");
                                String date = rs.getString("Date&Time");
                                %>
                                <tr>
                                    <td><%= question_id %></td>
                                    <td><%= question_text %></td>
                                    <td><%= question_type %></td>
                                    <td><%= question_level %></td>
                                    <td><%= date %></td>
                                </tr>
                                <%
                            }
                            %>
                        </table>
                        <input type="button"id="CloseQuestionReport" value="Close" onclick="CloseQuestionReport()">
                    </div>

            <%
                } catch (Exception e) {
                    e.printStackTrace();
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
            }
            %>

                </div>


                <div class="report">
                    <form method="post" action=" ">
                        <input type="date" name="startDate" placeholder="Starting Date" required>
                        <input type="date" name="endDate" placeholder="Ending Date" required>
                    
                        <input type="submit" name="FeedbackReport" value="Feedback Report">
                    </form>
                    <%
                    if (request.getParameter("FeedbackReport") != null) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");

                        String startDate = request.getParameter("startDate");
                        String endDate = request.getParameter("endDate");

                        String userDataQuery = "SELECT * FROM feedback WHERE `Date&Time` BETWEEN ? AND ?";

                        pst = con.prepareStatement(userDataQuery);
                        pst.setString(1, startDate);
                        pst.setString(2, endDate);

                        rs = pst.executeQuery();
                    %>
                    <div class="displayFeedbackReport" id="displayFeedbackReport">
                        <h1>Feedback Report</h1>
                        <table class="reportTable">
                            <tr>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Message</th>
                                <th>Date</th>
                            </tr>
                            <%
                            while (rs.next()) {
                                String name = rs.getString("name");
                                String email = rs.getString("email");
                                String message = rs.getString("message");
                                String date = rs.getString("Date&Time");
                            %>
                                <tr>
                                    <td><%= name %></td>
                                    <td><%= email %></td>
                                    <td><%= message %></td>
                                    <td><%= date %></td>
                                </tr>
                            <%
                            }
                            %>
                        </table>
                        <input type="button"id="CloseFeedbackReport" value="Close" onclick="CloseFeedbackReport()">
                    </div>
            <%
                } catch (Exception e) {
                    e.printStackTrace();
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
            }
            %>

                </div>
            </div>


        </div>


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

            var welcome = document.getElementById("welcomeDiv");
            var addQueDiv = document.getElementById("addingquetionsdiv");
            var userDetailDiv = document.getElementById("UserDetailDiv");
            var displayQueDiv = document.getElementById("AddedQueDiv");
            var FeedbackDiv = document.getElementById("FeedbackDiv");
            var report = document.getElementById("ReportsDiv");
            var UserReport = document.getElementById("displayUserReport");
            var QuestionReport = document.getElementById("displayQuestionReport");
            var FeedbackReport = document.getElementById("displayFeedbackReport");
            var closeUser = document.getElementById("closeUserReport");
            var closeQuestion = document.getElementById("closeQuestionReport");
            var closeFeedback = document.getElementById("closeFeedbackReport");

            function openNewPage() {
                welcome.style.display = 'none';
                addQueDiv.style.display = 'block';
                userDetailDiv.style.display = 'none';
                displayQueDiv.style.display = 'none';
                FeedbackDiv.style.display = 'none';
                report.style.display = 'none';
                UserReport.style.display = 'none';
                QuestionReport.style.display = 'none';
                FeedbackReport.style.display = 'none';
            }
            

            function openUserDetail() {
                welcome.style.display = 'none';
                addQueDiv.style.display = 'none';
                userDetailDiv.style.display = 'block';
                displayQueDiv.style.display = 'none';
                FeedbackDiv.style.display = 'none';
                report.style.display = 'none';
                UserReport.style.display = 'none';
                QuestionReport.style.display = 'block';
                FeedbackReport.style.display = 'none';
            }

            function openAddedQue() {
                welcome.style.display = 'none';
                addQueDiv.style.display = 'none';
                userDetailDiv.style.display = 'none';
                displayQueDiv.style.display = 'block';
                FeedbackDiv.style.display = 'none';
                report.style.display = 'none';
                UserReport.style.display = 'none';
                QuestionReport.style.display = 'none';
                FeedbackReport.style.display = 'none';
            }

            function openFeedback() {
                welcome.style.display = 'none';
                addQueDiv.style.display = 'none';
                userDetailDiv.style.display = 'none';
                displayQueDiv.style.display = 'none';
                FeedbackDiv.style.display = 'block';
                report.style.display = 'none';
                UserReport.style.display = 'none';
                QuestionReport.style.display = 'none';
                FeedbackReport.style.display = 'none';
            }

            function openReport() {
                welcome.style.display = 'none';
                addQueDiv.style.display = 'none';
                userDetailDiv.style.display = 'none';
                displayQueDiv.style.display = 'none';
                FeedbackDiv.style.display = 'none';
                report.style.display = 'block';

            }


            function CloseUserReport(){
                UserReport.style.display = 'none';
            }

            function CloseQuestionReport(){
                QuestionReport.style.display = 'none';
            }
            function CloseFeedbackReport(){
                FeedbackReport.style.display = 'none';
            }

            </script>
    </body>
</html>
<%
} 
else {
    
    response.sendRedirect("cred.jsp");
}
%>