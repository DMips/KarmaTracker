KarmaTracker.controller "TasksController", ($scope, $http, $cookieStore, $location, $routeParams, broadcastService, $rootScope) ->
  $rootScope.pullAllowed = true
  $scope.tasks = []
  $scope.current = true
  $scope.query.string = ""
  $scope.tokenName = 'token'
  $scope.timer = 0
  $scope.currentPage = 0
  $scope.pageSize = KarmaTrackerConfig.items_per_page
  $scope.totalCount = 0
  $scope.items = []

  $scope.numberOfPages = ->
    return Math.ceil($scope.totalCount/$scope.pageSize)

  $scope.reloadTasks = (pageNr) ->
    $rootScope.loading = true
    if !pageNr? || isNaN(pageNr) || typeof(pageNr) == 'boolean'
      pageNr = 0

    $http.get(
      "/api/v1/projects/#{$routeParams.project_id}/#{if $scope.current then "current_" else "" }tasks?token=#{$cookieStore.get($scope.tokenName)}#{if $scope.query.string.length > 0 then '&query=' + $scope.query.string else ''}&page=#{pageNr+1}"
    ).success((data, status, headers, config) ->
      $scope.totalCount = parseInt(data['total_count'])
      $scope.currentPage = pageNr
      $scope.tasks = []
      for task in data['tasks']
        task.task.visible = true
        $scope.tasks.push task.task
       $scope.initItems()
       $rootScope.loading = false
    ).error((data, status, headers, config) ->
      $rootScope.loading = false
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
      )

  $scope.queryChanged = () ->
    query = $scope.query.string
    clearTimeout $scope.timer if $scope.timer != 0
    $scope.timer = setTimeout (->
      $scope.reloadTasks()
      $scope.$apply()
    ), 1000

  $scope.reloadTasks()
  $scope.$watch("current", $scope.reloadTasks)
  $scope.$watch("runningTask", $scope.reloadTasks)
  $scope.$watch("query.string", $scope.queryChanged)


  $http.get(
    "/api/v1/projects/#{$routeParams.project_id}/?token=#{$cookieStore.get($scope.tokenName)}"
  ).success((data, status, headers, config) ->
    $scope.project = data.project
  ).error((data, status, headers, config) ->
  )

  $scope.initItems = ->
    $scope.items = []
    numberOfPages = $scope.numberOfPages()
    for i in [0..(numberOfPages-1)]
      $scope.items.push { text: "#{i+1}/#{numberOfPages}", value: i }

  broadcastService.prepForBroadcast "TasksControllerStarted"
