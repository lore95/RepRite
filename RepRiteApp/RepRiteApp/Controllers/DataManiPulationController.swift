import Foundation

class DataManipulationController {
    // MARK: - Properties
    private var previousEWMAX: Float = 0.0
    private var previousEWMAY: Float = 0.0
    private var previousEWMAZ: Float = 0.0
    private let ewmaAlpha: Float
    private let complementaryAlpha: Float

    init(ewmaAlpha: Float = 0.2, complementaryAlpha: Float = 0.98) {
        self.ewmaAlpha = ewmaAlpha
        self.complementaryAlpha = complementaryAlpha
    }

    // MARK: - Filter Raw IMU Data (EWMA)
    func filterIMUData(x: Float, y: Float, z: Float) -> (
        filteredX: Float, filteredY: Float, filteredZ: Float
    ) {
        let filteredX = ewmaAlpha * x + (1 - ewmaAlpha) * previousEWMAX
        let filteredY = ewmaAlpha * y + (1 - ewmaAlpha) * previousEWMAY
        let filteredZ = ewmaAlpha * z + (1 - ewmaAlpha) * previousEWMAZ

        previousEWMAX = filteredX
        previousEWMAY = filteredY
        previousEWMAZ = filteredZ

        return (filteredX, filteredY, filteredZ)
    }

    // MARK: - Sensor Fusion (Complementary Filter)
    func fuseData(acceleration: Float, gyroscope: Float) -> Float {
        return complementaryAlpha * acceleration + (1 - complementaryAlpha)
            * gyroscope
    }

    // MARK: - Calculate 2D Angle in X-Y Plane
    func calculate2DAngle(x: Float, y: Float) -> Float {
        let angleRad = atan2(y, x)  // Returns angle in radians
        let angleDeg = angleRad * 180 / .pi
        return angleDeg >= 0 ? angleDeg : angleDeg + 360  // Ensure 0-360 degrees
    }
    // MARK: - Calculate 3D Angle As instructed in lab
    func calculateVaried3dAngle(x: Float, y: Float, z: Float) -> (
        tiltAngle: Float, roll: Float, pitch: Float
    ) {
        let magnitude = sqrt(x * x + y * y + z * z)
          guard magnitude != 0 else { return (0, 0, 0) }
          
          let normX = x / magnitude
          let normY = y / magnitude
          let normZ = z / magnitude

          // Adjust tilt angle: Map Z to desired range (0-180°)
          let tiltAngle = acos(normZ) * 180 / .pi

          // Roll: Rotation around X-axis
          let roll = atan2(normY, normZ) * 180 / .pi

          // Pitch: Rotation around Y-axis
          let pitch = atan2(-normX, sqrt(normY * normY + normZ * normZ)) * 180 / .pi

          // Print for debugging
          print("Normalized Z: \(normZ), Tilt Angle: \(tiltAngle), Roll: \(roll), Pitch: \(pitch)")

          return (tiltAngle, roll, pitch)

    }
    // MARK: - Calculate 3D Angle (Tilt Relative to Z-Axis)
    func calculateAngleToXis(x: Float, y: Float, z: Float) -> (
        zAngle: Float, roll: Float, pitch: Float
    ) {
        let magnitude = sqrt(x * x + y * y + z * z)
        guard magnitude != 0 else { return (0, 0, 0) }

        // Angle with respect to Z-axis
        let zAngle = acos(z / magnitude) * 180 / .pi

        // Roll (rotation around X-axis) and Pitch (rotation around Y-axis)
        let roll = atan2(y, z) * 180 / .pi
        let pitch = atan2(-x, sqrt(y * y + z * z)) * 180 / .pi

        return (zAngle, roll, pitch)
    }
}
