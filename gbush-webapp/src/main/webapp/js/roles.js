/**
 * Author: Per Spilling, per@kodemaker.no
 */
var myApp = angular.module('roles', ['ngResource', 'ui.bootstrap'], function ($dialogProvider) {
    $dialogProvider.options({backdropClick: false, dialogFade: true});
});

/**
 * Configure the PersonsResource. In order to solve the Single Origin Policy issue in the browser
 * I have set up a Jetty proxy servlet to forward requests transparently to the API server.
 * See the web.xml file for details on that.
 */
myApp.factory('RolesResource', function ($resource) {
    return $resource('/api/role', {}, {});
});

myApp.factory('RolesResource', function ($resource) {
    return $resource('/api/role/:id', {}, {});
});

function RolesCtrl($scope, RolesResource, RolesResource, $dialog, $q) {
    /**
     * Define an object that will hold data for the form. The persons list will be pre-loaded with the list of
     * persons from the server. The personForm.person object is bound to the person form in the HTML via the
     * ng-model directive.
     */
    $scope.roleForm = {
        show: true,
        role: {}
    }
    $scope.roles = RolesResource.query();

    /**
     * Function used to toggle the show variable between true and false, which in turn determines if the person form
     * should be displayed of not.
     */
    $scope.toggleRoleForm = function () {
        $scope.roleForm.show = !$scope.roleForm.show;
    }

    /**
     * Clear the person data from the form.
     */
    $scope.clearForm = function () {
        $scope.roleForm.roles = {}
    }

    /**
     * Save a person. Make sure that a role object is present before calling the service.
     */
    $scope.saveRole = function (role) {
        if (role != undefined) {
            /**
             * Here we need to ensure that the RolesResource.query() is done after the RolesResource.save. This
             * is achieved by using the $promise returned by the $resource object.
             */
            RolesResource.save(role).$promise.then(function() {
                $scope.roles = RolesResource.query();
                $scope.roleForm.role = {}  // clear the form
            });
        }
    }

    /**
     * Set the person to be edited in the person form.
     */
    $scope.editRole = function (p) {
        $scope.roleForm.role = p
    }

    /**
     * Delete a person. Present a modal dialog box to the user to make the user confirm that the person item really
     * should be deleted.
     */
    $scope.deleteRole = function (person) {
        var msgBox = $dialog.messageBox('You are about to delete a role from the database', 'This cannot be undone. Are you sure?', [
            {label: 'Yes', result: 'yes'},
            {label: 'Cancel', result: 'no'}
        ])
        msgBox.open().then(function (result) {
            if (result === 'yes') {
                // remove from the server and reload the person list from the server after the delete
                RolesResource.delete({id: role.id}).$promise.then(function() {
                    $scope.roles = RolesResource.query();
                });
            }
        });
    }
}

/*
 $scope.kodemakerPersons = {}
 $scope.persons = PersonsResource.query(function (response) {
 angular.forEach(response, function (person) {
 console.log('person.name=' + person.name)
 });
 });
 */