import SwiftUI

/// Central palette: coal blacks layered by elevation, ember orange as the single accent.
enum Theme {
    /// Window background — deepest coal.
    static let background = Color(red: 0.07, green: 0.07, blue: 0.08)
    /// Raised surfaces: tiles, bars.
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.12)
    /// Hovered/highlighted surface.
    static let surfaceRaised = Color(red: 0.15, green: 0.15, blue: 0.16)
    /// Hairline strokes on surfaces.
    static let stroke = Color.white.opacity(0.07)
    /// Ember orange accent.
    static let accent = Color(red: 1.0, green: 0.45, blue: 0.15)
    static let accentSoft = Color(red: 1.0, green: 0.45, blue: 0.15).opacity(0.15)
}
