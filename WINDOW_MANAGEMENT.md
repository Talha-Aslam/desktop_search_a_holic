# Window Management Features

## Fullscreen and Windowed Mode

The Desktop Search A Holic application now supports both fullscreen and windowed modes with proper constraints to prevent UI overflow.

### Features

#### 1. **Default Launch Mode**
- Application starts in **windowed mode** by default
- Initial window size: 1024x768 pixels
- Window is centered on screen

#### 2. **Window Size Constraints**
- **Minimum size**: 1024x768 pixels (locked, cannot be made smaller)
- **Maximum size**: Unlimited (users can resize as large as their screen allows)
- **Resizable**: Users can resize the window larger than minimum, but not smaller
- These constraints prevent widget overflow while allowing flexibility

#### 3. **Fullscreen Toggle Options**

**Keyboard Shortcuts:**
- `F11` - Toggle between fullscreen and windowed mode
- `Alt + Enter` - Alternative fullscreen toggle

**UI Controls:**
- **Dashboard**: Fullscreen toggle button in the top-right corner of the AppBar
- **Sidebar**: Fullscreen option in the navigation menu
- **Settings Page**: Dedicated Window & Display section with fullscreen toggle

#### 4. **Window Resizing**
- Users can freely resize the window to any size larger than 1024x768
- Window cannot be resized smaller than the minimum dimensions
- If window becomes too small, a warning message is displayed
- Application layout adapts to different window sizes above the minimum

#### 5. **Fullscreen Support**
- Toggle fullscreen mode using F11 key
- Exit fullscreen to return to windowed mode
- Fullscreen mode utilizes entire screen real estate

### Usage Instructions

1. **To resize the window:**
   - Drag window edges or corners to make it larger
   - Window cannot be made smaller than 1024x768 pixels
   - No maximum size limit - resize as large as your screen allows

2. **To enter fullscreen mode:**
   - Press `F11` key
   - Application uses entire screen

3. **To exit fullscreen mode:**
   - Press `F11` key again
   - Returns to windowed mode at previous size

### Technical Implementation

- Uses `window_manager` package for native window management
- Implements `FullscreenController` with Provider state management
- Keyboard shortcuts handled globally throughout the application
- Fullscreen state persists across different pages

### Benefits

- **Flexibility**: Users can resize window to their preference while maintaining minimum usability
- **Productivity**: Larger windows provide more workspace, fullscreen maximizes screen real estate
- **Reliability**: Minimum size constraints prevent UI overflow and layout issues
- **User Experience**: Smooth resizing with clear visual feedback
- **Compatibility**: Works on Windows, macOS, and Linux desktop platforms

### Troubleshooting

If you encounter issues with window management:
1. Ensure you're running on a desktop platform (not web)
2. Check that your screen resolution meets minimum requirements
3. Try using keyboard shortcuts if UI buttons are not responsive
4. Restart the application if window becomes unresponsive
