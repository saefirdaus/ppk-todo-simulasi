<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        return redirect('/todos')->with('success', 'Login berhasil!');
    }

    public function logout()
    {
        return redirect('/login')->with('success', 'Logout berhasil!');
    }
}