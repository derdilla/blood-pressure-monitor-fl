package com.derdilla.blood_pressure_app;


import androidx.core.content.FileProvider;

public class FileSharer extends FileProvider {
    public FileSharer() {
        super(R.xml.file_paths);
    }
}
