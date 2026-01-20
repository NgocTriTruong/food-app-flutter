package org.example.food_app_be.dto;

public class VerifyOtpRequest {
    private String idToken; // Firebase ID Token

    public String getIdToken() {
        return idToken;
    }

    public void setIdToken(String idToken) {
        this.idToken = idToken;
    }
}
