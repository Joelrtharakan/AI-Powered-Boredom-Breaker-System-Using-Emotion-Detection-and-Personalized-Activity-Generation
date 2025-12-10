import { createContext, useState, useContext, useEffect } from 'react';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [token, setToken] = useState(localStorage.getItem('token'));
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const u = localStorage.getItem('user');
        if (u) {
            setUser(JSON.parse(u));
        }
        if (token) {
            axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        }
    }, [token]);

    const login = async (email, password) => {
        setLoading(true);
        try {
            const res = await axios.post(`${API_URL}/auth/login`, { email, password });
            const tk = res.data.access_token;
            const rtk = res.data.refresh_token;
            const usr = res.data.user;
            setToken(tk);
            setUser(usr);
            localStorage.setItem('token', tk);
            localStorage.setItem('refresh_token', rtk);
            localStorage.setItem('user', JSON.stringify(usr));
            return true;
        } catch (e) {
            console.error(e);
            return false;
        } finally {
            setLoading(false);
        }
    };

    const register = async (data) => {
        setLoading(true);
        try {
            const res = await axios.post(`${API_URL}/auth/register`, data);
            const tk = res.data.access_token;
            const rtk = res.data.refresh_token;
            const usr = res.data.user;
            setToken(tk);
            setUser(usr);
            localStorage.setItem('token', tk);
            localStorage.setItem('refresh_token', rtk);
            localStorage.setItem('user', JSON.stringify(usr));
            return true;
        } catch (e) {
            console.error(e);
            return false;
        } finally {
            setLoading(false);
        }
    };

    const logout = async () => {
        try {
            const rtk = localStorage.getItem('refresh_token');
            if (rtk) {
                await axios.post(`${API_URL}/auth/logout`, { refresh_token: rtk });
            }
        } catch (e) { console.error("Logout failed on server", e); }

        setToken(null);
        localStorage.removeItem('token');
        localStorage.removeItem('refresh_token');
        localStorage.removeItem('user');
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, login, register, logout, token, loading }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
