using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Window_Editor : EditorWindow{
    // this specifies where to find the window
    [MenuItem("CustomizedEditor/Editor/Window_Editor")]

    // this method is to get the window class that derived from EditorWindow
    public static void ShowWindow()
    {
        Window_Editor self = (Window_Editor)GetWindow(typeof(Window_Editor));
        /* can also use GetWindowWithRect */
    }

    bool enableToggleGroup = false;
    private void OnGUI()
    {
        GUILayout.Label("Test Editor");
        EditorGUILayout.TextField("Text Fields", "place_holder");
        enableToggleGroup = EditorGUILayout.BeginToggleGroup("Optional", enableToggleGroup);
            EditorGUILayout.Toggle("Single Toggle", true);
            EditorGUILayout.Slider("Test Slider", 5, 0, 10);
        EditorGUILayout.EndToggleGroup();
    }

}
