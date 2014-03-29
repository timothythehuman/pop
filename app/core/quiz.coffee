Pop.Quiz = (params) ->
  @game = params.game
  @tense = params.tense
  @balloon = params.balloon
  @infinitive = params.infinitive
  @verb = @game.currentLanguage().findVerbByInfinitive @infinitive

  @questions = []

  for key, value of @verb.tenses[@tense]
    @questions.push new Pop.Question { game: @game, key: key, value: value }

  @correctAnswers = 0
  @wrongAnswers = 0
  @pendingAnswers = @questions.length

  @currentQuestionLocation = 0

  return

Pop.Quiz.prototype.currentQuestion = ->
  @questions[@currentQuestionLocation]

Pop.Quiz.prototype.firstQuestion = ->
  @currentQuestionLocation = 0
  @currentQuestion()

Pop.Quiz.prototype.nextQuestion = ->
  @currentQuestionLocation++
  if @currentQuestionLocation < @questions.length
    @currentQuestion()
  else
    @close()

Pop.Quiz.prototype.prepNextQuestion = ->
  Pop.Input.clear()
  @pendingAnswers -= 1
  @nextQuestion()

Pop.Quiz.prototype.submitAnswer = (answer) ->
  currentQuestion = @currentQuestion()
  if currentQuestion.checkAnswer(answer)
    Pop.sfxInflate.play()
    @correctAnswers += 1
    @balloon.inflation += Pop.Config.inflationRate
    @prepNextQuestion()
  else
    Pop.sfxDeflate.play()
    @wrongAnswers += 1
    @balloon.inflation -= Pop.Config.deflationRate
    if currentQuestion.attemptsRemaining > 0
      currentQuestion.attemptsRemaining -= 1
    else
      @prepNextQuestion()

Pop.Quiz.prototype.close = ->
  @game.roundManager.currentRound.setCurrentInfinitive()
  @game.roundManager.currentRound.currentQuiz = undefined
  @balloon.active = false
  unless @balloon.inflated
    @game.roundManager.currentRound.selectLowestBalloon()