
import Foundation

struct PersonFormModel {

    var name: String = ""
    var phone: String = ""
    var email: String = ""
    var notificationChannel: NotificationChannel = .email
    var avatar: String = availablePersonAvatars.randomElement() ?? "AvatarPerson01"
    var noGift: [UUID] = []
}

