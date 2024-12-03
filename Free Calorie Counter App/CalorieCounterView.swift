//
//  CalorieCounterView.swift
//  Free Calorie Counter App
//
//  Created by VLol on 10/25/24.
//
import SwiftUI
import Foundation

struct CalorieCounterView: View {
    @State private var showActivityInfo = false
    @State private var userData = UserData(
        currentWeight: 0,
        goalWeight: 0,
        height: 0,
        tdee: 0,
        caloriesConsumedToday: 0,
        calorieDeficit: 0,
        dailyWeightLoss: 0,
        age: 0,
        sex: "Male",
        caloriesBurnedFromExercise: 0,
        activityLevel: 1.2
    )
    @State private var useMetric = true  // Toggle between Metric and Imperial
    
    var body: some View {
        NavigationView {
            Form {
                // Measurement System Section
                Section(header: Text("Measurement System")) {
                    Toggle("Use Metric System", isOn: $useMetric)
                }
                
                // Enter Your Details Section
                Section(header: Text("Enter Your Details")) {
                    HStack {
                        Text("Age:")
                        Spacer()
                        TextField("25", value: $userData.age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Sex:")
                        Spacer()
                        Picker("Sex", selection: $userData.sex) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    HStack {
                        Text("Current Weight (\(useMetric ? "kg" : "lbs")):")
                        Spacer()
                        TextField("0", value: $userData.currentWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Goal Weight (\(useMetric ? "kg" : "lbs")):")
                        Spacer()
                        TextField("0", value: $userData.goalWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Height (\(useMetric ? "cm" : "inches")):")
                        Spacer()
                        TextField("0", value: $userData.height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("TDEE (kcal):")
                        Spacer()
                        TextField("0", value: $userData.tdee, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Daily Calorie Intake Section
                Section(header: Text("Daily Calorie Intake")) {
                    HStack {
                        Text("Calories Consumed Today:")
                        Spacer()
                        TextField("0", value: $userData.caloriesConsumedToday, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Calories Burned from Exercise:")
                        Spacer()
                        TextField("0", value: $userData.caloriesBurnedFromExercise, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Activity Level Section with Info Button
                Section(header: activityLevelHeader) {
                    Picker("Activity Level", selection: $userData.activityLevel) {
                        Text("Sedentary").tag(1.2)
                        Text("Lightly Active").tag(1.375)
                        Text("Moderately Active").tag(1.55)
                        Text("Very Active").tag(1.725)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Projected Weight Loss Section
                Section(header: Text("Projected Weight Loss")) {
                    
                    Text("Weekly Weight Loss: \(weeklyWeightLoss(), specifier: "%.2f") \(useMetric ? "kg" : "lbs")")
                    Text("Monthly Weight Loss: \(monthlyWeightLoss(), specifier: "%.2f") \(useMetric ? "kg" : "lbs")")
                    Text("Estimated Time to Goal: \(timeToReachGoal(), specifier: "%.1f") weeks")
                }
            }
            .navigationTitle("Calorie Counter")
            .sheet(isPresented: $showActivityInfo) {
                ActivityLevelInfoView()
            }
        }
    }
    
    // Custom Header View for the Activity Level Section
    private var activityLevelHeader: some View {
        HStack {
            Text("Activity Level")
            Spacer()
            Button(action: {
                showActivityInfo = true
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    // MARK: - Calculation Functions
    private func calculateBMR() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        let weight = useMetric ? userData.currentWeight : userData.currentWeight * 0.453592
        let height = useMetric ? userData.height : userData.height * 2.54
        
        if userData.sex == "Male" {
            return 66 + (13.75 * weight) + (5.003 * height) - (6.75 * Double(userData.age))
        } else {
            return 655 + (9.563 * weight) + (1.850 * height) - (4.676 * Double(userData.age))
        }
    }
    
    private func calculateTDEE() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        return calculateBMR() * userData.activityLevel
    }
    
    private func calorieDeficit() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        return max(0, calculateTDEE() - (userData.caloriesConsumedToday - userData.caloriesBurnedFromExercise))
    }
    
    private func dailyWeightLoss() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        return calorieDeficit() / (useMetric ? 7700.0 : 3500.0)
    }
    
    private func weeklyWeightLoss() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        return dailyWeightLoss() * 7
    }
    
    private func monthlyWeightLoss() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        return weeklyWeightLoss() * 4
    }
    
    private func timeToReachGoal() -> Double {
        guard inputsAreValid() else { return 0 } //checks if input is valid
        let weightDifference = userData.currentWeight - userData.goalWeight
        return abs(weightDifference) / weeklyWeightLoss()
    }
    
    //helper function
    //checks for non zero intputs
    
    private func inputsAreValid() -> Bool {
        // Check for non-zero and reasonable inputs
        return userData.currentWeight > 0 &&
               userData.goalWeight > 0 &&
               userData.height > 0 &&
               userData.tdee > 0 &&
               userData.caloriesConsumedToday > 0 &&
               userData.caloriesBurnedFromExercise >= 0
    }

    
    
}

// Subview for Activity Level Info Popup
struct ActivityLevelInfoView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Activity Level Definitions")
                    .font(.headline)
                    .padding(.bottom, 8)
                Text("• Sedentary: Little to no exercise.")
                Text("• Lightly Active: Exercise 1–3 times per week.")
                Text("• Moderately Active: Exercise 4–5 times per week.")
                Text("• Very Active: Daily exercise or intense workouts.")
                Spacer()
            }
            .padding()
            .navigationTitle("Activity Level Info")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}
