KarmaTracker.controller "TasksController", ($scope, $http, $cookieStore, $location, $routeParams, broadcastService) ->
  $scope.tasks = []
  $scope.current = true
  $scope.query.string = ""
  $scope.tokenName = 'token'

  $scope.reloadTasks = ->
    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/#{if $scope.current then "current_" else "" }tasks?token=#{$cookieStore.get($scope.tokenName)}#{if $scope.query.string.length > 0 then '&query=' + $scope.query.string else ''}"
    ).success((data, status, headers, config) ->
      console.log 'success'
      $scope.tasks = []
      for task in data
        task.task.visible = true
        $scope.tasks.push task.task

    ).error((data, status, headers, config) ->
      console.debug('Error fetching tasks')
    )


  $scope.startTracking = (task) ->
    if $scope.runningTask? && task.id == $scope.runningTask.id
      $http.post(
        "/api/v1/time_log_entries/stop?token=#{$cookieStore.get($scope.tokenName)}"
      ).success((data, status, headers, config) ->
        $scope.runningTask = null
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())

        broadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
        console.debug('Error when stopping time log entries')
      )
    else
      $http.post(
        "/api/v1/time_log_entries/?token=#{$cookieStore.get($scope.tokenName)}",
        { time_log_entry: {task_id: task.id} }
      ).success((data, status, headers, config) ->
        $scope.runningTask = task
        $scope.$watch("$scope.runningTask", $scope.getRunningTask())
        broadcastService.prepForBroadcast "refreshRecent"
      ).error((data, status, headers, config) ->
        console.debug('Error when starting tracking time on tasks')
      )


  $scope.reloadTasks()
  $scope.$watch("current", $scope.reloadTasks)
  $scope.$watch("runningTask", $scope.reloadTasks)
  $scope.$watch "query.string", $scope.reloadTasks

  $http.get(
    "/api/v1/projects/#{$routeParams.project_id}/?token=#{$cookieStore.get($scope.tokenName)}"
  ).success((data, status, headers, config) ->
    $scope.project = data.project
  ).error((data, status, headers, config) ->
    console.debug('Error fetching project')
  )
