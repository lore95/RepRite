//
//  ExerciseSession.swift
//  RepRiteApp
//
//  Created by lorewnzo  on 2025-01-02.
//


import Foundation

struct ExerciseSession: Codable {
    let date: Date
    let exercises: [ExerciseData]
    let angles: [Double]
}

struct ExerciseData: Codable {
    let typeOfExercise: String
    let numberOfRepetitions: Int
}
