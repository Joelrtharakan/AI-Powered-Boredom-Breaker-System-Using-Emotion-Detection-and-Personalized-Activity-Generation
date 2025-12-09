import { createContext, useState, useContext, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [token, setToken] = useState(localStorage.getItem('token'));
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (token) {
            axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
            // Simulating user load
            setUser({ name: "User", email: "user@example.com" });
        }
    }, [token]);

    const login = async (email, password) => {
        setLoading(true);
        try {
            const res = await axios.post('http://localhost:8000/api/v1/auth/login', { email, password });
            const tk = res.data.access_token;
            setToken(tk);
            localStorage.setItem('token', tk);
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
            const res = await axios.post('http://localhost:8000/api/v1/auth/register', data);
            const tk = res.data.access_token;
            setToken(tk);
            localStorage.setItem('token', tk);
            return true;
        } catch (e) {
            console.error(e);
            return false;
        } finally {
            setLoading(false);
        }
    };

    const logout = () => {
        setToken(null);
        localStorage.removeItem('token');
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, login, register, logout, token, loading }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
