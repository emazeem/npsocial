class AppUrl {
  //live link
  //static var url = 'https://app.thenpsocial.com/';

  //staging link
  static var url = 'https://condescending-knuth.3-19-145-255.plesk.page/';
  static var baseUrl = url + 'api/';

  static var loginUrl = baseUrl + 'login';
  static var registeUrl = baseUrl + 'register';
  static var afterRejectionUrl = baseUrl + 'user/update';
  static var verifyEmail = baseUrl + 'verify-email';
  static var fetchUser = baseUrl + 'user/fetch';
  static var fetchAllUsers = baseUrl + 'all-users';
  static var fetchUserDetail = baseUrl + 'user/detail';
  static var updateSocialInfo = baseUrl + 'user/update-profile';
  static var updateLocation = baseUrl + 'user/update-location';
  static var fetchSpecialities = baseUrl + 'speciality/fetch';
  static var updateSpeciality = baseUrl + 'speciality/update';
  static var fetchFriends = baseUrl + 'friend/fetch';
  static var fetchSearchUsers = baseUrl + 'search';
  static var fetchAllPosts = baseUrl + 'post/fetch/all';
  static var fetchAllTwoPosts = baseUrl + 'post/fetch/all/show-more';
  static var fetchSinglePost = baseUrl + 'post/fetch/post';
  static var fetchMyPosts = baseUrl + 'post/fetch/my-posts/show-more';
  static var deleteMyPosts = baseUrl + 'post/delete';
  static var createPost = baseUrl + 'post/create';
  static var fetchAllComments = baseUrl + 'post/fetch/comment';
  static var reportPosts = baseUrl + 'post/report/store';
  static var storeComments = baseUrl + 'comment/store';
  static var deleteComments = baseUrl + 'comment/delete';
  static var fetchReplyComments = baseUrl + 'comment/fetch/reply';
  static var editComments = baseUrl + 'comment/update';
  static var storeDeviceId = baseUrl + 'user/store_device';
  static var removeDeviceId = baseUrl + 'user/remove_device';
  static var storeLikes = baseUrl + 'like/store';
  static var fetchLikes = baseUrl + 'like/fetch';
  static var changePassword = baseUrl + 'user/update/password';
  static var markAllMessagesAsRead = baseUrl + 'user/read-all-messages';
  static var sendFriendRequest = baseUrl + 'friend/send-request';
  static var unfriend = baseUrl + 'friend/remove';
  static var friendStatus = baseUrl + 'friend/status';
  static var friendOfMarketPlace = baseUrl + 'friend/marketplace';
  static var acceptOrRejectFriendRequest = baseUrl + 'friend/accept-reject';
  static var changeProfilePicture = baseUrl + 'user/update-profile-photo';
  static var changeCoverPicture = baseUrl + 'user/update-cover-photo';
  static var fetchGalleryImages = baseUrl + 'gallery/image';
  static var fetchNotifications = baseUrl + 'user/notifications';
  static var markAllNotificationAsRead =
      baseUrl + 'user/all-notifications/mark-as-read';

  static var forgetPassword = baseUrl + 'forgot-password';
  static var createNewPassword = baseUrl + 'create-new-password';
  static var deleteAccount = baseUrl + 'user/delete-account';
  static var friendRequest = baseUrl + 'friend/all-requests';
  static var userBlock = baseUrl + 'block/store';
  static var reportUser = baseUrl + 'user/report';
  static var fetchBlocklist = baseUrl + 'block/fetch';
  static var unBlock = baseUrl + 'block/remove';

  static var fetchPrivacy = baseUrl + 'privacy/fetch';
  static var updatePrivacy = baseUrl + 'privacy/update';
  static var checkPrivacy = baseUrl + 'privacy/check';

  //License
  static var storeLicense = baseUrl + 'license/store';
  static var fetchLicense = baseUrl + 'license/fetch';

  static var deleteLicense = baseUrl + 'license/delete';
  static var updateLicense = baseUrl + 'license/update';
  //Product
  static var fetchCategory = baseUrl + 'product/categories';
  static var storeProduct = baseUrl + 'product/store';
  static var fetchProduct = baseUrl + 'product/fetch-all';
  static var fetchProductDetails = baseUrl + 'product/fetch';
  static var removeProduct = baseUrl + 'product/delete';
  static var productImageBaseUrl = AppUrl.url + 'storage/products/';
  //Nearme
  static var fetchNearmeUser = baseUrl + 'other-user/fetch/long-lat';

  //case study
  static var storeCaseStudy = baseUrl + 'case-study/store';
  static var fetchCaseStudy = baseUrl + 'case-study/fetch/all';
  static var deleteCaseStudy = baseUrl + 'case-study/delete';

  static var createGroup = baseUrl + 'groups/store';
  static var updateCover = baseUrl + 'groups/update_cover';
  static var fetchGroups = baseUrl + 'groups/fetch/all';
  static var inviteFromGroupToUsers = baseUrl + 'groups/invite-to-users';
  static var groupDetailsbyId = baseUrl + 'groups/fetch';
  static var groupRequestsReceivedToMe =
      baseUrl + 'groups/requests-received-to-me';
  static var groupRequestsReceivedToGroup =
      baseUrl + 'groups/requests-received-on-group';
  static var fetchGroupMembers = baseUrl + 'groups/members';
  static var groupRequestAction = baseUrl + 'groups/request-action';
  static var groupSendJoinRequest = baseUrl + 'groups/join';
  static var groupPost = baseUrl + 'groups/posts';
  static var groupUpdate = baseUrl + 'groups/update';
  static var removeMember = baseUrl + 'groups/member/remove';
  static var groupMembersforTagging = baseUrl + 'groups/members/tagging';

  static var storeConference = baseUrl + 'events/store';
  static var deleteConferencs = baseUrl + 'events/delete';
  static var fetchAllConferences = baseUrl + 'events/fetch/all';
  static var fetchEventsByDate = baseUrl + 'events/fetch/by-date';
  static var fetchCountOfEventsByMonth = baseUrl + 'events/fetch/by-month';
  static var storeEventCount = baseUrl + 'events/poll/store';
  static var eventsPollFetch = baseUrl + 'events/fetch/polls';
  static var fetchFollowers = baseUrl + 'follow/fetch';
  static var followStatus = baseUrl + 'follow/status';

  static var fetchAllMessages = baseUrl + 'chat/fetch';
  static var storeMessages = baseUrl + 'chat/store';
  static var fetchChatFriends = baseUrl + 'chat/friends';

  static var removeFollower = baseUrl + 'follow/remove';
  static var addFollower = baseUrl + 'follow';

  //ads
  static var registerImpression = baseUrl + 'ads/add-states';
  //jobs
  static var storeJob = baseUrl + 'job/store';
  static var fetchJobs = baseUrl + 'job/fetch-all';
  static var applyJob = baseUrl + 'job/apply';
  static var updateJob = baseUrl + 'job/update';
  static var deleteJob = baseUrl + 'job/delete';
  static var fetchJobDetails = baseUrl + 'job/fetch';
}
