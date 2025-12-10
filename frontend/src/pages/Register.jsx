import { motion } from 'framer-motion';
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Check, ChevronRight, User, Mail, Lock, ArrowRight, Loader2, Star, Sparkles, Target, Zap } from 'lucide-react';

const interestsList = [
    { name: "Fitness", icon: Zap },
    { name: "Productivity", icon: Target },
    { name: "Music", icon: Sparkles },
    { name: "Creativity", icon: Star },
    { name: "Games", icon: Sparkles },
    { name: "Mindfulness", icon: Zap },
    { name: "Motivation", icon: Target },
    { name: "Relaxation", icon: Star }
];

export default function Register() {
    const { register } = useAuth();
    const navigate = useNavigate();
    const [step, setStep] = useState(1);
    const [loading, setLoading] = useState(false);
    const [focusedField, setFocusedField] = useState(null);
    const [formData, setFormData] = useState({
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
        interests: []
    });

    const toggleInterest = (interestName) => {
        setFormData(prev => ({
            ...prev,
            interests: prev.interests.includes(interestName)
                ? prev.interests.filter(i => i !== interestName)
                : [...prev.interests, interestName]
        }));
    };

    const handleNext = () => setStep(step + 1);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        // Simulate cinematic delay
        await new Promise(r => setTimeout(r, 1000));

        const success = await register({
            email: formData.email,
            password: formData.password,
            username: formData.username
        });

        setLoading(false);
        if (success) navigate('/dashboard');
        else alert('Registration failed');
    };

    return (
        <div className="flex min-h-screen bg-[#050505] text-white overflow-x-hidden relative selection:bg-white/20 flex-col lg:flex-row">

            {/* Left Side (Visuals) */}
            <div className="hidden lg:flex w-full lg:w-1/2 relative items-center justify-center p-12 overflow-hidden min-h-[300px] lg:min-h-screen bg-[#080808] border-r border-white/5">
                <div className="absolute inset-0">
                    <div className="absolute top-0 left-0 w-full h-[1px] bg-gradient-to-r from-transparent via-white/10 to-transparent" />
                    <motion.div
                        animate={{ opacity: [0.3, 0.6, 0.3] }}
                        transition={{ duration: 4, repeat: Infinity }}
                        className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-blue-900/20 via-[#050505] to-[#050505]"
                    />
                </div>

                <div className="relative z-10 max-w-lg space-y-10">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8 }}
                    >
                        <h1 className="text-6xl font-bold tracking-tighter leading-[1.1] mb-6">
                            Join the <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-cyan-400">Revolution.</span>
                        </h1>
                        <p className="text-xl text-gray-400 font-light leading-relaxed">
                            Unlock your full potential with personalized AI guidance. Your journey to a better state of mind starts here.
                        </p>
                    </motion.div>

                    <div className="grid grid-cols-2 gap-6">
                        {[
                            { title: "Smart", desc: "Adaptive AI" },
                            { title: "Private", desc: "Encrypted Vault" },
                            { title: "Fast", desc: "Real-time Plans" },
                            { title: "Fun", desc: "Gamified" }
                        ].map((item, i) => (
                            <motion.div
                                key={i}
                                initial={{ opacity: 0, x: -10 }}
                                animate={{ opacity: 1, x: 0 }}
                                transition={{ delay: 0.4 + (i * 0.1) }}
                                className="p-4 rounded-xl bg-white/5 border border-white/5"
                            >
                                <div className="font-bold text-white mb-1">{item.title}</div>
                                <div className="text-xs text-gray-500 uppercase tracking-widest">{item.desc}</div>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </div>

            {/* Right Side (Form) */}
            <div className="w-full lg:w-1/2 flex items-center justify-center p-6 sm:p-12 relative">
                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.6 }}
                    className="w-full max-w-md relative z-10"
                >
                    {/* Step Indicator */}
                    <div className="flex items-center gap-2 mb-8">
                        <div className={`h-1 flex-1 rounded-full transition-colors duration-300 ${step >= 1 ? 'bg-white' : 'bg-white/10'}`} />
                        <div className={`h-1 flex-1 rounded-full transition-colors duration-300 ${step >= 2 ? 'bg-white' : 'bg-white/10'}`} />
                    </div>

                    <div className="mb-8">
                        <h2 className="text-3xl font-bold tracking-tight mb-2">Create Account</h2>
                        <p className="text-gray-400">{step === 1 ? "Enter your credentials to get started." : "Personalize your experience."}</p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-6">
                        {step === 1 ? (
                            <div className="space-y-5">
                                {/* Username */}
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-gray-300 ml-1">Username</label>
                                    <div className={`relative transition-all duration-300 rounded-xl bg-white/5 border ${focusedField === 'username' ? 'border-white/40 ring-1 ring-white/10' : 'border-white/10'}`}>
                                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                            <User className={`h-5 w-5 transition-colors ${focusedField === 'username' ? 'text-white' : 'text-gray-500'}`} />
                                        </div>
                                        <input
                                            type="text"
                                            className="block w-full pl-11 pr-4 py-4 bg-transparent text-white placeholder-gray-600 focus:outline-none rounded-xl"
                                            placeholder="johndoe"
                                            value={formData.username}
                                            onChange={e => setFormData({ ...formData, username: e.target.value })}
                                            onFocus={() => setFocusedField('username')}
                                            onBlur={() => setFocusedField(null)}
                                        />
                                    </div>
                                </div>

                                {/* Email */}
                                <div className="space-y-2">
                                    <label className="text-sm font-medium text-gray-300 ml-1">Email</label>
                                    <div className={`relative transition-all duration-300 rounded-xl bg-white/5 border ${focusedField === 'email' ? 'border-white/40 ring-1 ring-white/10' : 'border-white/10'}`}>
                                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                            <Mail className={`h-5 w-5 transition-colors ${focusedField === 'email' ? 'text-white' : 'text-gray-500'}`} />
                                        </div>
                                        <input
                                            type="email"
                                            className="block w-full pl-11 pr-4 py-4 bg-transparent text-white placeholder-gray-600 focus:outline-none rounded-xl"
                                            placeholder="name@example.com"
                                            value={formData.email}
                                            onChange={e => setFormData({ ...formData, email: e.target.value })}
                                            onFocus={() => setFocusedField('email')}
                                            onBlur={() => setFocusedField(null)}
                                        />
                                    </div>
                                </div>

                                {/* Passwords */}
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <label className="text-sm font-medium text-gray-300 ml-1">Password</label>
                                        <div className={`relative transition-all duration-300 rounded-xl bg-white/5 border ${focusedField === 'password' ? 'border-white/40 ring-1 ring-white/10' : 'border-white/10'}`}>
                                            <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                                <Lock className={`h-5 w-5 transition-colors ${focusedField === 'password' ? 'text-white' : 'text-gray-500'}`} />
                                            </div>
                                            <input
                                                type="password"
                                                className="block w-full pl-11 pr-4 py-4 bg-transparent text-white placeholder-gray-600 focus:outline-none rounded-xl"
                                                value={formData.password}
                                                onChange={e => setFormData({ ...formData, password: e.target.value })}
                                                onFocus={() => setFocusedField('password')}
                                                onBlur={() => setFocusedField(null)}
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-sm font-medium text-gray-300 ml-1">Confirm</label>
                                        <div className={`relative transition-all duration-300 rounded-xl bg-white/5 border ${focusedField === 'confirm' ? 'border-white/40 ring-1 ring-white/10' : 'border-white/10'}`}>
                                            <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                                <Lock className={`h-5 w-5 transition-colors ${focusedField === 'confirm' ? 'text-white' : 'text-gray-500'}`} />
                                            </div>
                                            <input
                                                type="password"
                                                className="block w-full pl-11 pr-4 py-4 bg-transparent text-white placeholder-gray-600 focus:outline-none rounded-xl"
                                                value={formData.confirmPassword}
                                                onChange={e => setFormData({ ...formData, confirmPassword: e.target.value })}
                                                onFocus={() => setFocusedField('confirm')}
                                                onBlur={() => setFocusedField(null)}
                                            />
                                        </div>
                                    </div>
                                </div>

                                <button
                                    type="button"
                                    onClick={handleNext}
                                    className="w-full bg-white text-black font-bold py-4 rounded-xl flex items-center justify-center gap-2 hover:bg-gray-100 transition-colors group shadow-[0_0_20px_rgba(255,255,255,0.1)] hover:shadow-[0_0_30px_rgba(255,255,255,0.3)] duration-300 mt-4"
                                >
                                    Continue <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                                </button>
                            </div>
                        ) : (
                            <motion.div
                                initial={{ opacity: 0, x: 20 }}
                                animate={{ opacity: 1, x: 0 }}
                                className="space-y-6"
                            >
                                <div className="grid grid-cols-2 gap-3">
                                    {interestsList.map((interest) => {
                                        const Icon = interest.icon;
                                        const isSelected = formData.interests.includes(interest.name);
                                        return (
                                            <button
                                                key={interest.name}
                                                type="button"
                                                onClick={() => toggleInterest(interest.name)}
                                                className={`p-4 rounded-xl border text-sm font-medium transition-all duration-200 flex flex-col items-center gap-2 ${isSelected
                                                        ? 'bg-white text-black border-white scale-[1.02]'
                                                        : 'bg-white/5 border-white/10 text-gray-400 hover:bg-white/10 hover:border-white/20'
                                                    }`}
                                            >
                                                <Icon className={`w-6 h-6 ${isSelected ? 'text-black' : 'text-gray-500'}`} />
                                                {interest.name}
                                            </button>
                                        )
                                    })}
                                </div>

                                <div className="flex gap-4">
                                    <button
                                        type="button"
                                        onClick={() => setStep(1)}
                                        className="w-1/3 py-4 rounded-xl border border-white/10 hover:bg-white/5 transition-colors font-medium text-gray-400"
                                    >
                                        Back
                                    </button>
                                    <button
                                        type="submit"
                                        disabled={loading}
                                        className="flex-1 bg-white text-black font-bold py-4 rounded-xl flex items-center justify-center gap-2 hover:bg-gray-100 transition-colors group shadow-[0_0_20px_rgba(255,255,255,0.1)] hover:shadow-[0_0_30px_rgba(255,255,255,0.3)] duration-300 disabled:opacity-70"
                                    >
                                        {loading ? <Loader2 className="animate-spin" /> : "Complete Setup"}
                                    </button>
                                </div>
                            </motion.div>
                        )}

                        <div className="text-center text-sm pt-6 border-t border-white/5">
                            <span className="text-gray-500">Already have an account? </span>
                            <button
                                type="button"
                                onClick={() => navigate('/login')}
                                className="text-white font-medium hover:underline underline-offset-4 decoration-gray-500"
                            >
                                Sign In
                            </button>
                        </div>
                    </form>
                </motion.div>
            </div>
        </div>
    );
}
