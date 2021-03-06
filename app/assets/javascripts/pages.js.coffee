jQuery ->
  $.each streams.users, (user) ->
    getJSONP(user)
  $("time.timeago").timeago();
  channel.bind 'pusher:subscription_succeeded', ->
    channel.trigger('client-new_message', {'message': 'working', 'user':'pusher'})
    console.log 'bind now'
  channel.bind 'new_message', (data) ->
    console.log data
    unless data.user == Object.keys(users)
      createUserStream(data.user)
    user = data.user || randomUser()
    message = data.message || randomMessage()
    tweet = writeTweet(message,user)
    renderTweet(tweet)
  channel.bind 'iphone', (data) ->
    iphone.alert(data.message)
  pusher.connection.bind 'state_change', (states) ->
  # states = {previous: 'oldState', current: 'newState'}
    $('div#status').text "Pusher's current state is " + states.current
  iphone.init()
  $tweetStream.on 'click','a.user', clickNames
  $('#tweetUser').on 'blur', ->
    tweetUser = $(this).val() || "visitor"
    unless tweetUser == Object.keys(users)
      createUserStream(tweetUser)
  $('#tweetUser').on 'keydown', (e) ->
    if e.keyCode == 13
      e.preventDefault()
      $('#new_message').focus()
  $('#new_message').on 'input', (e) ->
    message = $(this).val()
    console.log message
    key_value = 140 - +message.length
    if key_value < 0
      value = 'style="color:red">' + key_value + ''
      $('#postTweet').attr("disabled", "disabled")
    else
      value = '>' + key_value + ''
      $('#postTweet').removeAttr('disabled')
    $('h6').html('<span ' + value + ' characters remaining</span>')
  $('#postTweet').on 'click', ->
    user = $('#tweetUser').val() || "visitor"
    message = $('#new_message').val() || randomMessage()
    if liveMode
      channel.trigger 'client-new_message', { 'user': user, 'message': message }
      liveTweet { 'user': user, 'message': message}
    tweet = writeTweet(message,user)
    renderTweet(tweet)
    $('#new_message').val('')
    $('h6').html('<span>140 characters remaining</span>')
  $('#randomFakeTweet').on 'click', ->
    if currentUser
      generateRandomTweet(currentUser);
    else
      generateRandomTweet();
    tweet = streams.home[tweetIndex]
    renderTweet(tweet)
  $('#liveFakeTweet').on 'click', ->
    if $(this).hasClass 'btn-info'
      stopLiveFakeTweets()
      $(this).button('toggle').removeClass('btn-info')
    else
      liveFakeTweets()
      $(this).button('toggle').addClass('btn-info')
  $('#clearTweets').on 'click', clearTweets
  $('body').append '<div id="banner"><a href="http://hackreactor.com/" target="_blank">Built at HackReactor</a></div></a>'

