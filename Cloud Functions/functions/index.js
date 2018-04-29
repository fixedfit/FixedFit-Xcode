function onCreateAddFollowers(snap, context) {
  const usersList = snap.val()
  const currentUserID = context.params.userID
  const addedUserID = usersList[0]
  const followingCount = 1
  const newFollowers = [currentUserID]

  // Update the person who just followed someone following's count
  return root.child(`users/${currentUserID}/followingCount`).set(followingCount).then(function() {
      // Fetch the person who was just followed, followers list
      return root.child(`users/${addedUserID}/followers`).once('value').then((snap, context) => {
        var usersList = new Array()
        var newFollowersCount = 0

        if (Array.isArray(snap.val())) {
          usersList = snap.val()
          usersList.push(currentUserID)
          newFollowersCount = usersList.length
        } else {
          usersList.push(currentUserID)
          newFollowersCount = 1
        }

        // Update the person who just was followed, followers list
        return root.child(`users/${addedUserID}/followers`).set(usersList).then(function() {
          // Update the person who was just followed followers count
          return root.child(`users/${addedUserID}/followersCount`).set(newFollowersCount).then(function() {
            // Fetch current user username
            return root.child(`users/${currentUserID}/username`).once(`value`).then((snap, context) => {
              // Add to notifications array "$(username) followed you"
              const currentUserUsername = snap.val()
              const notification = currentUserUsername + " followed you"

              return root.child(`users/${addedUserID}/notifications`).once(`value`).then((snap, context) => {
                var foundNotifications = new Array()

                if (Array.isArray(snap.val())) {
                  foundNotifications = snap.val()
                  foundNotifications.unshift(notification)
                } else {
                  foundNotifications.push(notification)
                }

                return root.child(`users/${addedUserID}/notifications`).set(foundNotifications)
              });
            })
          })
        });
      });
  });
}

function onUpdateAddFollowers(snap, context) {
  const beforeUpdateUsersList = snap.before.val()
  const afterUpdatedUsersList = snap.after.val()
  const currentUserID = context.params.userID
  const followingCount = afterUpdatedUsersList.length

  // Check if the update is an adding or deleting of following users
  if (afterUpdatedUsersList.length > beforeUpdateUsersList.length) {
    // Update the person who just followed someone following's count
    const addedUserID = afterUpdatedUsersList[afterUpdatedUsersList.length - 1]

    // Update the person who just followed someone following's count
    return root.child(`users/${currentUserID}/followingCount`).set(followingCount).then(function() {
        // Fetch the person who was just followed, followers list
        return root.child(`users/${addedUserID}/followers`).once('value').then((snap, context) => {
          var usersList = new Array()
          var newFollowersCount = 0

          if (Array.isArray(snap.val())) {
            usersList = snap.val()
            usersList.push(currentUserID)
            newFollowersCount = usersList.length
          } else {
            usersList.push(currentUserID)
            newFollowersCount = 1
          }

          // Update the person who just was followed, followers list
          return root.child(`users/${addedUserID}/followers`).set(usersList).then(function() {
            // Update the person who was just followed followers count
            return root.child(`users/${addedUserID}/followersCount`).set(newFollowersCount).then(function() {
              // Fetch current user username
              return root.child(`users/${currentUserID}/username`).once(`value`).then((snap, context) => {
                // Add to notifications array "$(username) followed you"
                const currentUserUsername = snap.val()
                const notification = currentUserUsername + " followed you"

                return root.child(`users/${addedUserID}/notifications`).once(`value`).then((snap, context) => {
                  var foundNotifications = new Array()

                  if (Array.isArray(snap.val())) {
                    foundNotifications = snap.val()
                    foundNotifications.unshift(notification)
                  } else {
                    foundNotifications.push(notification)
                  }

                  return root.child(`users/${addedUserID}/notifications`).set(foundNotifications)
                });
              })
            })
          });
        });
    });
  } else if (afterUpdatedUsersList.length < beforeUpdateUsersList.length) {
    const deletedUserID = beforeUpdateUsersList[beforeUpdateUsersList.length - 1]

    // Update the person who just followed someone following's count
    return root.child(`users/${currentUserID}/followingCount`).set(followingCount).then(function() {
      // Update the person who was just unfollowed, follower's list
      return root.child(`users/${deletedUserID}/followers`).once('value').then((snap, context) => {
          const usersList = snap.val()

          var updatedUserList = usersList.filter(function(userID) {
            if (userID == currentUserID) { return false } else { return true }
          })
          var newFollowersCount = updatedUserList.length

          return root.child(`users/${deletedUserID}/followers`).set(updatedUserList).then(function() {
            return root.child(`users/${deletedUserID}/followersCount`).set(newFollowersCount);
          })
      });
    });
  }
}

function onDeleteRemoveFollowers(snap, context) {
  const usersList = snap.val()
  const currentUserID = context.params.userID
  const followingCount = 0
  const deletedUserID = usersList[usersList.length - 1]

  // Update the person who just followed someone following's count
  return root.child(`users/${currentUserID}/followingCount`).set(followingCount).then(function() {
    // Update the person who was just unfollowed, follower's list
    return root.child(`users/${deletedUserID}/followers`).once('value').then((snap, context) => {
        const usersList = snap.val()

        var updatedUserList = usersList.filter(function(userID) {
          if (userID == currentUserID) { return false } else { return true }
        })
        var newFollowersCount = updatedUserList.length

        return root.child(`users/${deletedUserID}/followers`).set(updatedUserList).then(function() {
          return root.child(`users/${deletedUserID}/followersCount`).set(newFollowersCount);
        })
    });
  });
  return 0;
}

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
var root = admin.database().ref()

exports.createAddFollowers = functions.database.ref('/users/{userID}/following').onCreate(onCreateAddFollowers);
exports.updateAddFollowers = functions.database.ref('/users/{userID}/following').onUpdate(onUpdateAddFollowers);
exports.deleteAddFollowers= functions.database.ref('/users/{userID}/following').onDelete(onDeleteRemoveFollowers);