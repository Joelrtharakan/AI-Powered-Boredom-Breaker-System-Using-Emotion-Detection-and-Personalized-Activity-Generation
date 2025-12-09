import { motion } from 'framer-motion';
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { User, Lock, ArrowRight, Github } from 'lucide-react';

export default function Login() {
    const { login } = useAuth();
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        // Simulate login delay for animation
        await new Promise(r => setTimeout(r, 1000));
        const success = await login(email, password);
        setLoading(false);
        if (success) navigate('/dashboard');
        else alert('Login failed. Check console.');
    };

    return (
        <div className="flex items-center justify-center min-h-screen relative overflow-hidden">
            {/* Background elements */}
            <div className="absolute top-[-20%] left-[-10%] w-[60vw] h-[60vw] rounded-full bg-primary-dark/20 blur-[150px] animate-blob" />
            <div className="absolute bottom-[-20%] right-[-10%] w-[60vw] h-[60vw] rounded-full bg-neon-purple/10 blur-[150px] animate-blob animation-delay-2000" />

            <motion.div
                initial={{ opacity: 0, scale: 0.9, y: 30 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                transition={{ duration: 0.6, type: "spring", stiffness: 100 }}
                className="relative z-10 glass-card w-full max-w-md mx-4 p-8 md:p-10 border-white/10"
            >
                {/* Logo & Header */}
                <div className="text-center mb-10">
                    <motion.div
                        animate={{ rotate: [0, 5, -5, 0] }}
                        transition={{ duration: 4, repeat: Infinity }}
                        className="mx-auto mb-6 w-20 h-20 shadow-[0_0_30px_rgba(109,40,217,0.4)] rounded-2xl overflow-hidden"
                    >
                        <img src="/logo.png" alt="Logo" className="w-full h-full object-cover" />
                    </motion.div>
                    <h1 className="text-4xl font-black title-gradient mb-2 tracking-tight">Welcome Back</h1>
                    <p className="text-gray-400 font-light">Enter your credentials to access your space.</p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-6">
                    <div className="space-y-2">
                        <label className="text-sm text-gray-400 ml-1">Email Address</label>
                        <div className="relative">
                            <User className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 w-5 h-5" />
                            <input
                                type="email"
                                placeholder="name@example.com"
                                className="input-field pl-12"
                                value={email}
                                onChange={e => setEmail(e.target.value)}
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm text-gray-400 ml-1">Password</label>
                        <div className="relative">
                            <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 w-5 h-5" />
                            <input
                                type="password"
                                placeholder="••••••••"
                                className="input-field pl-12"
                                value={password}
                                onChange={e => setPassword(e.target.value)}
                            />
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="btn-primary w-full py-4 text-lg shadow-neon-blue/20"
                    >
                        {loading ? 'Authenticating...' : 'Sign In'}
                    </button>

                    <div className="relative flex py-2 items-center">
                        <div className="flex-grow border-t border-gray-700"></div>
                        <span className="flex-shrink mx-4 text-gray-500 text-sm">Or continue with</span>
                        <div className="flex-grow border-t border-gray-700"></div>
                    </div>

                    <button type="button" onClick={() => navigate('/dashboard')} className="w-full py-3 bg-white/5 hover:bg-white/10 rounded-xl border border-white/10 transition-colors text-gray-300 font-medium text-sm flex items-center justify-center gap-2">
                        Continue as Guest <ArrowRight className="w-4 h-4" />
                    </button>

                    <div className="text-center mt-6">
                        <span className="text-gray-500">New here? </span>
                        <button type="button" onClick={() => navigate('/register')} className="text-neon-purple hover:text-white transition-colors font-medium">
                            Create Account
                        </button>
                    </div>
                </form>
            </motion.div>
        </div>
    );
}
