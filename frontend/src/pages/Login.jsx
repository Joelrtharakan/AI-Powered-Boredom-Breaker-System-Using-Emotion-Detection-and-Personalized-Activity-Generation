import { motion } from 'framer-motion';
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Mail, Lock, ArrowRight, Loader2 } from 'lucide-react';

export default function Login() {
    const { login } = useAuth();
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [focusedField, setFocusedField] = useState(null);
    const [isResetting, setIsResetting] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        // Subtle delay for UX
        await new Promise(r => setTimeout(r, 800));

        if (isResetting) {
            try {
                // Direct call for reset since it's one-off
                await axios.post('http://localhost:8000/api/auth/reset-password', {
                    email,
                    new_password: password
                });
                alert("Password reset successfully! Please login with your new password.");
                setIsResetting(false);
                setPassword('');
            } catch (err) {
                console.error(err);
                try {
                    // Fallback to v1 if the above fails (handling inconsistent legacy prefixes)
                    await axios.post('http://localhost:8000/api/v1/auth/reset-password', {
                        email,
                        new_password: password
                    });
                    alert("Password reset successfully! Please login with your new password.");
                    setIsResetting(false);
                    setPassword('');
                } catch (e2) {
                    alert("Failed to reset password. Check if email exists.");
                }
            }
        } else {
            const success = await login(email, password);
            if (success) navigate('/dashboard');
            else alert('Login failed. Please check your credentials.');
        }
        setLoading(false);
    };

    return (
        <div className="flex min-h-screen bg-slate-50 text-txt-main overflow-x-hidden relative selection:bg-primary/20 flex-col lg:flex-row">
            {/* Split Layout: Left Side (Visuals) */}
            <div className="hidden lg:flex w-full lg:w-1/2 relative items-center justify-center p-12 overflow-hidden min-h-[300px] lg:min-h-screen">
                {/* Abstract animated shapes */}
                <div className="absolute inset-0">
                    <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 100, repeat: Infinity, ease: "linear" }}
                        className="absolute -top-[50%] -left-[50%] w-[1000px] h-[1000px] rounded-[40%] border border-slate-900/5 opacity-30"
                    />
                    <motion.div
                        animate={{ rotate: -360 }}
                        transition={{ duration: 150, repeat: Infinity, ease: "linear" }}
                        className="absolute top-[20%] right-[20%] w-[600px] h-[600px] rounded-full border border-slate-900/5 opacity-20"
                    />
                </div>

                {/* Showcase Text */}
                <div className="relative z-10 max-w-lg space-y-8">
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, delay: 0.2 }}
                        className="text-7xl font-bold tracking-tighter leading-tight text-slate-900"
                    >
                        Escaping<br />
                        The<br />
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">Ordinary.</span>
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 0.8, delay: 0.4 }}
                        className="text-xl text-txt-muted font-light leading-relaxed"
                    >
                        Turn idle moments into sparks of joy. Your AI companion for creativity, productivity, and fun.
                    </motion.p>

                    {/* Stats or Trusted By (Mock) */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 0.8, delay: 0.6 }}
                        className="flex gap-8 pt-8 border-t border-slate-200"
                    >
                        <div>
                            <div className="text-3xl font-bold text-slate-900">Zero</div>
                            <div className="text-sm text-txt-muted uppercase tracking-wider mt-1">Dull Moments</div>
                        </div>
                        <div>
                            <div className="text-3xl font-bold text-slate-900">100%</div>
                            <div className="text-sm text-txt-muted uppercase tracking-wider mt-1">Engagement</div>
                        </div>
                    </motion.div>
                </div>

                {/* Gradient orb for ambient light */}
                <div className="absolute bottom-0 left-0 w-full h-[500px] bg-gradient-to-t from-blue-900/10 to-transparent blur-3xl pointer-events-none" />
            </div>

            {/* Split Layout: Right Side (Form) */}
            <div className="w-full lg:w-1/2 flex items-center justify-center p-8 relative">
                {/* Mobile Background Blob */}
                <div className="lg:hidden absolute -top-20 -right-20 w-80 h-80 bg-blue-600/20 rounded-full blur-[100px]" />

                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.6 }}
                    className="w-full max-w-md space-y-10 relative z-10"
                >
                    <div className="space-y-2">
                        <div className="w-12 h-12 bg-slate-900 rounded-xl mb-6 flex items-center justify-center">
                            <div className="w-6 h-6 bg-white rounded-full" />
                        </div>
                        <h2 className="text-3xl font-bold tracking-tight text-slate-900">{isResetting ? "Reset Password" : "Welcome back"}</h2>
                        <p className="text-txt-muted">{isResetting ? "Enter your email and a new password." : "Please enter your details to sign in."}</p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-6">
                        {/* Email Input */}
                        <motion.div
                            animate={focusedField === 'email' ? { scale: 1.02 } : { scale: 1 }}
                            className="space-y-2"
                        >
                            <label className="text-sm font-medium text-txt-muted ml-1">Email</label>
                            <div className={`relative transition-all duration-300 rounded-xl bg-white border ${focusedField === 'email' ? 'border-primary ring-1 ring-primary/20' : 'border-slate-200'}`}>
                                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                    <Mail className={`h-5 w-5 transition-colors ${focusedField === 'email' ? 'text-primary' : 'text-slate-400'}`} />
                                </div>
                                <input
                                    type="email"
                                    className="block w-full pl-11 pr-4 py-4 bg-transparent text-slate-900 placeholder-slate-400 focus:outline-none rounded-xl"
                                    placeholder="name@company.com"
                                    value={email}
                                    onChange={e => setEmail(e.target.value)}
                                    onFocus={() => setFocusedField('email')}
                                    onBlur={() => setFocusedField(null)}
                                    required
                                />
                            </div>
                        </motion.div>

                        {/* Password Input */}
                        <motion.div
                            animate={focusedField === 'password' ? { scale: 1.02 } : { scale: 1 }}
                            className="space-y-2"
                        >
                            <label className="text-sm font-medium text-txt-muted ml-1">{isResetting ? "New Password" : "Password"}</label>
                            <div className={`relative transition-all duration-300 rounded-xl bg-white border ${focusedField === 'password' ? 'border-primary ring-1 ring-primary/20' : 'border-slate-200'}`}>
                                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                    <Lock className={`h-5 w-5 transition-colors ${focusedField === 'password' ? 'text-primary' : 'text-slate-400'}`} />
                                </div>
                                <input
                                    type="password"
                                    className="block w-full pl-11 pr-4 py-4 bg-transparent text-slate-900 placeholder-slate-400 focus:outline-none rounded-xl"
                                    placeholder={isResetting ? "New secure password" : "••••••••"}
                                    value={password}
                                    onChange={e => setPassword(e.target.value)}
                                    onFocus={() => setFocusedField('password')}
                                    onBlur={() => setFocusedField(null)}
                                    required
                                />
                            </div>
                        </motion.div>

                        {/* Submit Button */}
                        <motion.button
                            whileHover={{ scale: 1.01 }}
                            whileTap={{ scale: 0.99 }}
                            type="submit"
                            disabled={loading}
                            className={`w-full font-bold py-4 rounded-xl flex items-center justify-center gap-2 transition-colors disabled:opacity-70 disabled:cursor-not-allowed group shadow-lg hover:shadow-xl duration-300 ${isResetting ? "bg-red-500 text-white hover:bg-red-600" : "bg-primary text-white hover:bg-primary-dark"}`}
                        >
                            {loading ? (
                                <Loader2 className="animate-spin w-5 h-5" />
                            ) : (
                                <>
                                    {isResetting ? "Update Password" : "Sign In"}
                                    <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                                </>
                            )}
                        </motion.button>

                        <div className="text-center text-sm space-y-2">
                            <div>
                                <span className="text-gray-500">Don't have an account? </span>
                                <button
                                    type="button"
                                    onClick={() => navigate('/register')}
                                    className="text-primary font-bold hover:underline underline-offset-4 decoration-primary/30"
                                >
                                    Sign up for free
                                </button>
                            </div>
                            <button
                                type="button"
                                onClick={() => setIsResetting(!isResetting)}
                                className="text-txt-muted text-xs hover:text-primary transition-colors"
                            >
                                {isResetting ? "Back to Login" : "Forgot Password?"}
                            </button>
                        </div>
                    </form>

                    {/* Minimal Footer */}
                    <div className="pt-12 text-xs text-gray-600 flex justify-between">
                        <a href="#" className="hover:text-gray-400 transition-colors">Privacy Policy</a>
                        <a href="#" className="hover:text-gray-400 transition-colors">Terms of Service</a>
                    </div>
                </motion.div>
            </div>
        </div>
    );
}
