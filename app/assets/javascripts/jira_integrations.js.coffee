KarmaTracker.controller "JIRAIntegrationsController", ($scope, $http, $cookieStore, $location) ->
  $scope.integrations = []
  $scope.newIntegration = { username: null, password: null, api_key: null }
  $scope.addFormShown = false
  $scope.errors = {}
  $scope.tokenName = 'token'

  $scope.updateIntegrations = () ->
    $http.get(
      '/api/v1/integrations?token='+$cookieStore.get($scope.tokenName)+'&service=jira'
    ).success((data, status, headers, config) ->
      $scope.integrations = data
    ).error((data, status, headers, config) ->
    )

  $scope.remove = (id) ->
    answer = confirm("Are you sure to remove Pivotal Tracker Integration?")
    if answer
      $http.delete(
        '/api/v1/integrations/'+id+'?token='+$cookieStore.get($scope.tokenName)+'&service=jira'
      ).success((data, status, headers, config) ->
        $scope.updateIntegrations()
      ).error((data, status, headers, config) ->
      )

  $scope.formLooksValid = () ->
    valid = true
    $scope.errors = {}

    unless $scope.newIntegration.api_key? and $scope.newIntegration.api_key != ''
      for field in ["username", "password"]
        unless $scope.newIntegration[field]? and $scope.newIntegration[field] != ''
          $scope.errors[field] = "can't be blank"
          valid = false
    valid

  $scope.add = () ->
    if $scope.formLooksValid()
      if $scope.newIntegration.api_key? and $scope.newIntegration.api_key != ''
        $http.post(
          '/api/v1/integrations/jira?token='+$cookieStore.get($scope.tokenName)+'&integration[username]='+$scope.newIntegration.username_token+'&integration[api_key]='+$scope.newIntegration.api_key
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIntegrations()
        ).error((data, status, headers, config) ->
          console.debug data
          if data.jira.errors.api_key?
            $scope.errors.api_key = data.jira.errors.api_key[0]
          else
            $scope.errors.username_token = data.jira.errors.username[0]
            $scope.errors.api_key = data.jira.errors.password[0]
        )
      else
        $http.post(
          '/api/v1/integrations/jira?token='+$cookieStore.get($scope.tokenName)+'&integration[username]='+$scope.newIntegration.username+'&integration[password]='+$scope.newIntegration.password
        ).success((data, status, headers, config) ->
          $scope.cleanForm()
          $scope.openAddForm()
          $scope.updateIntegrations()
        ).error((data, status, headers, config) ->
          console.debug data
          $scope.newIntegration.username = ''
          $scope.newIntegration.password = ''
          if data.jira.errors.api_key?
            $scope.errors.password = data.jira.errors.api_key[0]
          else
            $scope.errors.password = data.jira.errors.password[0]
        )

  $scope.openAddForm = () ->
    $scope.addFormShown = !$scope.addFormShown
    $scope.cleanForm()

  $scope.cleanForm = () ->
    $scope.newIntegration.username = ''
    $scope.newIntegration.password = ''
    $scope.newIntegration.api_key = ''
    $scope.newIntegration.username_token = ''
    $scope.errors = {}


  $scope.updateIntegrations()
