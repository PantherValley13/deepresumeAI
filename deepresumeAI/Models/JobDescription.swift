
struct JobDescription: Codable {
    var title: String
    var company: String
    var description: String
    var keywords: [String]
    var requiredSkills: [String]
    var preferredSkills: [String]
    
    init(title: String = "",
         company: String = "",
         description: String = "",
         keywords: [String] = [],
         requiredSkills: [String] = [],
         preferredSkills: [String] = []) {
        self.title = title
        self.company = company
        self.description = description
        self.keywords = keywords
        self.requiredSkills = requiredSkills
        self.preferredSkills = preferredSkills
    }
}
