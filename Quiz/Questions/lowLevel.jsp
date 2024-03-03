<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Page</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/question.css">
    
</head>
<body>
    
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
      response.sendRedirect("index.jsp"); // Redirect to the home page or any other appropriate page after logout
    }
  }
  %>
 <%
  if (loggedInUser != null) {
    
 %>

 <div class="rules" id="rules">
    <p class="ruleCont">
        <ol class="rule">
            <li>The decision of the quiz-master will be final and will not be subjected to any change.</li>
            <li>The participants shall not be allowed to use mobile or other electronic instruments during the quiz time.</li>
            <li>The questions shall be in the form of multiple choice.</li>
            <li>Audience/Supporters shall not give any hints or clues to the competitors.</li>
        </ol>
        <p>All the Best !</p>
    </p>
    <button onclick="displayQuestionsNow()">Start Quiz</button>
</div> 

  <%@ page import="java.util.ArrayList" %>
    <%
        String questionLevel = "low"; 
        String selectedOption = request.getParameter("selectedOption");
        
        ArrayList<String> questions = new ArrayList<>();
        ArrayList<String> optionsA = new ArrayList<>();
        ArrayList<String> optionsB = new ArrayList<>();
        ArrayList<String> optionsC = new ArrayList<>();
        ArrayList<String> optionsD = new ArrayList<>();
        ArrayList<String> correctOptions = new ArrayList<>();
        ArrayList<Integer> timeLeftPerQuestion = new ArrayList<>(); 
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/quiz", "root", "");

            String sql = "SELECT * FROM questions WHERE question_level = ? ORDER BY RAND() LIMIT ?";

            int numberOfQuestionsToFetch = 10;

            pst = con.prepareStatement(sql);

            pst.setString(1, questionLevel);   
            pst.setInt(2, numberOfQuestionsToFetch);

            rs = pst.executeQuery();

            int questionNumber = 0; // Initialize the question number

            if (rs.next()) {
                do {
                    // Retrieve question information and add it to the ArrayLists
                    String questionText = rs.getString("question_text");
                    String optionA = rs.getString("option_a");
                    String optionB = rs.getString("option_b");
                    String optionC = rs.getString("option_c");
                    String optionD = rs.getString("option_d");
                    String correctOption = rs.getString("correct_option");

                    questions.add(questionText);
                    optionsA.add(optionA);
                    optionsB.add(optionB);
                    optionsC.add(optionC);
                    optionsD.add(optionD);
                    correctOptions.add(correctOption);
                    timeLeftPerQuestion.add(30);

                    if (questionNumber >= numberOfQuestionsToFetch) {
                        break;
                    }
                    
                %>

                    <div class="cont question-<%= questionNumber %>" id="contQuestion" style="display: none;"> 
                        <div id="timer<%= questionNumber %>">Time Left: 10 seconds</div>
                        <p><%= questionNumber+1 %>. <%= questionText %></p>
                        <br>
                        <input type="radio" id="selectedOptionA<%= questionNumber %>" name="selectedOption<%= questionNumber %>" value="A"><%= optionA %>
                        <br>
                        <input type="radio" id="selectedOptionB<%= questionNumber %>" name="selectedOption<%= questionNumber %>" value="B"><%= optionB %>
                        <br>
                        <input type="radio" id="selectedOptionC<%= questionNumber %>" name="selectedOption<%= questionNumber %>" value="C"><%= optionC %>
                        <br>
                        <input type="radio" id="selectedOptionD<%= questionNumber %>" name="selectedOption<%= questionNumber %>" value="D"><%= optionD %>
                        <br>
                        <input type="button" id="next<%= questionNumber %>" class="next-button" value="Next" onclick="showNextQuestion('<%= questionNumber %>', '<%= correctOption %>')">
                    
                        <div class="submit-button">
                            <input type="button" id="submitQuiz" onclick="submitQuiz()" value="Submit Quiz">
                        </div>
                    </div>

                <%
                    questionNumber++; // Increment the question number
                } while (rs.next());
            }

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("Database error: " + e.getMessage());
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
    %>

<div class="result" id="result" style="display: none;">
    <h1 style="text-align: center;">Result</h1>
    <p class="title">Quiz completed</p>
    <p class="correctanswer" id="correctanswer"></p>
    <p class="wronganswer" id="wronganswer"></p>
    <p class="unanswered" id="unanswered"></p>

    <% // Loop through the questions and display them at the end
        for (int i = 0; i < questions.size(); i++) {
    %>
    <div class="question">
        <p style="margin-bottom: 5px;"><%= i+1 %>. <%= questions.get(i) %></p>
        <p>A: <%= optionsA.get(i) %></p>
        <p>B: <%= optionsB.get(i) %></p>
        <p>C: <%= optionsC.get(i) %></p>
        <p>D: <%= optionsD.get(i) %></p>
        <p style="color: #4CAF50; margin-bottom: 5px;">Answer: <%= correctOptions.get(i) %></p>
    </div>
    <% } %>
</div>

<script>
    var currentQuestionIndex = 0;
    var contQuestion = document.getElementById('contQuestion')
    var rules = document.getElementById('rules')
    var questionDivs = document.querySelectorAll('.cont');
    var resultDiv = document.getElementById('result');
    var correctanswer = document.getElementById('correctanswer');
    var wronganswer = document.getElementById('wronganswer');
    var unanswered = document.getElementById('unanswered');
    var unmarked = 0;
    var correct = 0;
    var wrong = 0;
    var timer;

    function createAlertBox(message, type) {
        var alertBox = document.createElement('div');
        alertBox.className = 'alertBox ' + type;
        alertBox.innerHTML = '<span class="closebtn" onclick="this.parentElement.style.display=\'none\';">&times;</span>' + message;
        document.body.appendChild(alertBox);

        setTimeout(function() {
            alertBox.style.display = 'none';
            
        }, 1000);
        
    }


    function showSuccessAlert(message) {
        createAlertBox(message, 'success');
    }

    function showErrorAlert(message) {
        createAlertBox(message, 'error');
    }

    function showWarningAlert(message) {
        createAlertBox(message, 'warning');
    }

    function displayQuestionsNow(){
        contQuestion.style.display = 'block';
        rules.style.display = 'none';
        startTimer(currentQuestionIndex);

    }
    function showNextQuestion(questionNumber, correctOption) {
        var selectedOption = document.querySelector('input[name="selectedOption' + questionNumber + '"]:checked');

        if (!selectedOption) {
            showWarningAlert("Not selected question.");
            unmarked++;
        } else {
            if (selectedOption.value === correctOption) {
                showSuccessAlert("Your answer is correct!");
                correct++;
            } else {
                showErrorAlert("Your answer is incorrect.");
                wrong++;
            }
        }

        if(timer===0){
            showNextQuestion(questionNumber, correctOption);
        }

        if (currentQuestionIndex < questionDivs.length - 1) {
            clearInterval(timer);
            questionDivs[currentQuestionIndex].style.display = 'none';
            currentQuestionIndex++;
            questionDivs[currentQuestionIndex].style.display = 'block';
            startTimer(currentQuestionIndex); 
        } else {
            
            questionDivs.forEach(function (div) {
                div.style.display = 'none';
                clearInterval(timer);
            });

            resultDiv.style.display = 'block';
            unanswered.textContent = "Unanswered: " + unmarked;
            correctanswer.textContent = "Correct: " + correct;
            wronganswer.textContent = "Wrong: " + wrong;
        }
    }

    function startTimer(questionIndex) {
    
        var timerElement = document.getElementById('timer' + questionIndex);
        var timeLeft = 30; 

        timerElement.textContent = 'Time Left: ' + timeLeft + ' seconds';

        timer = setInterval(function () {
            timeLeft--;

            timerElement.textContent = 'Time Left: ' + timeLeft + ' seconds';

            if (timeLeft <= 0) {
                clearInterval(timer); 
                showErrorAlert("Time's up!");
                showNextQuestion(currentQuestionIndex, 0);
            }
        }, 1000); 
    }

    
    for (var i = 1; i < questionDivs.length; i++) {
        questionDivs[i].style.display = 'none';
    }
     
    function submitQuiz(){
        clearInterval(timer); 
        questionDivs.forEach(function (div) {
                div.style.display = 'none';
            });
            
            resultDiv.style.display = 'block';
            unanswered.textContent = "Unanswered: " + unmarked;
            correctanswer.textContent = "Correct: " + correct;
            wronganswer.textContent = "Wrong: " + wrong;       

    }
</script>

</body>
</html>
<%
} 
else {
    
    response.sendRedirect("/Quiz/nav/cred.jsp");
}
%>