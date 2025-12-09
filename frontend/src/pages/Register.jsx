import { motion } from 'framer-motion';
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

export default function Register() {
    const { register } = useAuth();
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [username, setUsername] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        const success = await register({ email, password, username });
        if (success) navigate('/');
        else alert('Registration failed');
    };

    return (
        <div className="flex items-center justify-center min-h-screen relative overflow-hidden">
            <div className="absolute top-0 left-0 w-full h-full bg-dark -z-10">
                <div className="absolute bottom-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-accent/20 blur-[120px]" />
                <div className="absolute top-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
            </div>

            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="relative z-10 glass-card w-full max-w-md mx-4"
            >
                <h1 className="text-3xl font-bold text-center mb-6">Join the Journey</h1>

                <form onSubmit={handleSubmit} className="space-y-4">
                    <input
                        type="text"
                        placeholder="Username"
                        className="input-field"
                        value={username}
                        onChange={e => setUsername(e.target.value)}
                    />
                    <input
                        type="email"
                        placeholder="Email"
                        className="input-field"
                        value={email}
                        onChange={e => setEmail(e.target.value)}
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        className="input-field"
                        value={password}
                        onChange={e => setPassword(e.target.value)}
                    />
                    <button type="submit" className="btn-primary w-full mt-4">
                        Create Account
                    </button>
                    <div className="text-center mt-4">
                        <button type="button" onClick={() => navigate('/login')} className="text-sm text-gray-400 hover:text-white transition-colors">
                            Already have an account? Login
                        </button>
                    </div>
                </form>
            </motion.div>
        </div>
    );
}
