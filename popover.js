(function(){
  angular.module('DemoApp', ['ui.bootstrap']);
  this.MainCtrl = function($scope, $http, orderByFilter){
    var url, $iframe;
    console.info('main');
    return;
    url = "http://50.116.42.77:3001";
    $scope.selectedModules = [];
    $iframe = $("<iframe>").css('display', 'none').appendTo(document.body);
    $scope.showBuildModal = function(){
      console.info(url);
      $scope.buildModalShown = true;
      if (!$scope.modules) {
        return $http.get(url + "/api/bootstrap").then(response(function(){
          return $scope.modules = response.data.modules;
        }), function(){
          return $scope.buildGetErrorText = "Error retrieving build files from server.";
        });
      }
    };
    return $scope.downloadBuild = function(){
      var downloadUrl;
      console.info(url);
      downloadUrl = url + "/api/bootstrap/download?";
      angular.forEach($scope.selectedModules, function(module){
        return downloadUrl += "modules=" + module + "&";
      });
      $iframe.attr('src', '');
      $iframe.attr('src', downloadUrl);
      return $scope.buildModalShown = false;
    };
  };
  this.PopoverDemoCtrl = function($scope){
    console.info('popover');
    $scope.dynamicPopover = "Hello, World!";
    $scope.dynamicPopoverText = "dynamic";
    return $scope.dynamicPopoverTitle = "Title";
  };
  this.DropdownCtrl = function($scope){
    console.info('dropdown');
    return $scope.items = ["The first choice!", "And another choice for you.", "but wait! A third!"];
  };
}).call(this);
