import SwiftUI

struct ResumeEditorView: View {
    @Binding var resume: Resume
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $resume.personalInfo.name)
                    TextField("Email", text: $resume.personalInfo.email)
                    TextField("Phone", text: $resume.personalInfo.phone)
                    TextField("Address", text: $resume.personalInfo.address)
                    TextField("LinkedIn", text: $resume.personalInfo.linkedIn)
                    TextField("Portfolio", text: $resume.personalInfo.portfolio)
                }
                
                Section(header: Text("Experience")) {
                    ForEach($resume.experiences) { $experience in
                        ExperienceView(experience: $experience)
                    }
                    .onDelete { indices in
                        resume.experiences.remove(atOffsets: indices)
                    }
                    
                    Button("Add Experience") {
                        resume.experiences.append(Experience(
                            id: UUID(),
                            jobTitle: "",
                            company: "",
                            duration: "",
                            responsibilities: []
                        ))
                    }
                }
                
                Section(header: Text("Education")) {
                    ForEach($resume.education) { $edu in
                        EducationView(education: $edu)
                    }
                    .onDelete { indices in
                        resume.education.remove(atOffsets: indices)
                    }
                    
                    Button("Add Education") {
                        resume.education.append(Education(
                            id: UUID(),
                            degree: "",
                            institution: "",
                            year: ""
                        ))
                    }
                }
                
                Section(header: Text("Skills")) {
                    ForEach($resume.skills) { $skill in
                        HStack {
                            TextField("Skill", text: $skill.name)
                            Picker("Level", selection: $skill.level) {
                                Text("Beginner").tag("Beginner")
                                Text("Intermediate").tag("Intermediate")
                                Text("Advanced").tag("Advanced")
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .onDelete { indices in
                        resume.skills.remove(atOffsets: indices)
                    }
                    
                    Button("Add Skill") {
                        resume.skills.append(Skill(
                            id: UUID(),
                            name: "",
                            level: "Intermediate"
                        ))
                    }
                }
            }
            .navigationTitle("Edit Resume")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExperienceView: View {
    @Binding var experience: Experience
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Job Title", text: $experience.jobTitle)
            TextField("Company", text: $experience.company)
            TextField("Duration", text: $experience.duration)
            
            ForEach($experience.responsibilities.indices, id: \.self) { index in
                HStack {
                    TextField("Responsibility", text: $experience.responsibilities[index])
                    Button(action: {
                        if experience.responsibilities.count > 1 {
                        experience.responsibilities.remove(at: index)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Button("Add Responsibility") {
                experience.responsibilities.append("")
            }
        }
    }
}

struct EducationView: View {
    @Binding var education: Education
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Degree", text: $education.degree)
            TextField("Institution", text: $education.institution)
            TextField("Year", text: $education.year)
        }
    }
}
