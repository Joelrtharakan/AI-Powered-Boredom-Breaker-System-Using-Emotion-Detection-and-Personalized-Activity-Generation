import { motion } from 'framer-motion';
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Check, ChevronRight, User, Mail, Lock } from 'lucide-react';

const interestsList = [
    "Fitness", "Productivity", "Music", "Creativity",
    "Games", "Bible Reflection", "Motivation", "Relaxation"
];

export default function Register() {
    const { register } = useAuth();
    const navigate = useNavigate();

    const [step, setStep] = useState(1);
    const [formData, setFormData] = useState({
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
        interests: []
    });

    const toggleInterest = (interest) => {
        setFormData(prev => ({
            ...prev,
            interests: prev.interests.includes(interest)
                ? prev.interests.filter(i => i !== interest)
                : [...prev.interests, interest]
        }));
    };

    const handleNext = () => setStep(step + 1);

    const handleSubmit = async (e) => {
        e.preventDefault();
        const success = await register({
            email: formData.email,
            password: formData.password,
            username: formData.username
        }); // In real apps, send interests too
        if (success) navigate('/dashboard');
        else alert('Registration failed');
    };

    return (
        <div className="flex items-center justify-center min-h-screen relative overflow-hidden px-4">
            <div className="absolute top-0 left-0 w-full h-full bg-dark">
                <div className="absolute top-[10%] right-[20%] w-[40vw] h-[40vw] rounded-full bg-primary/20 blur-[120px]" />
                <div className="absolute bottom-[10%] left-[10%] w-[30vw] h-[30vw] rounded-full bg-neon-pink/10 blur-[100px]" />
            </div>

            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="relative z-10 glass-card w-full max-w-lg p-0 overflow-hidden"
            >
                {/* Progress Bar */}
                <div className="h-2 bg-gray-800 w-full">
                    <motion.div
                        className="h-full bg-gradient-to-r from-primary to-neon-purple"
                        initial={{ width: '0%' }}
                        animate={{ width: step === 1 ? '50%' : '100%' }}
                    />
                </div>

                <div className="p-8 md:p-12">
                    <h1 className="text-3xl font-bold mb-2">Create Account</h1>
                    <p className="text-gray-400 mb-8 text-sm">Step {step} of 2: {step === 1 ? "Credentials" : "Your Interests"}</p>

                    <form onSubmit={handleSubmit} className="space-y-6">
                        {step === 1 ? (
                            <motion.div
                                initial={{ x: 20, opacity: 0 }}
                                animate={{ x: 0, opacity: 1 }}
                                className="space-y-4"
                            >
                                <div className="space-y-2">
                                    <label className="text-xs uppercase text-gray-500 font-bold tracking-wider ml-1">Username</label>
                                    <input
                                        type="text"
                                        className="input-field"
                                        value={formData.username}
                                        onChange={e => setFormData({ ...formData, username: e.target.value })}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-xs uppercase text-gray-500 font-bold tracking-wider ml-1">Email</label>
                                    <input
                                        type="email"
                                        className="input-field"
                                        value={formData.email}
                                        onChange={e => setFormData({ ...formData, email: e.target.value })}
                                    />
                                </div>
                                <div className="grid grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <label className="text-xs uppercase text-gray-500 font-bold tracking-wider ml-1">Password</label>
                                        <input
                                            type="password"
                                            className="input-field"
                                            value={formData.password}
                                            onChange={e => setFormData({ ...formData, password: e.target.value })}
                                        />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs uppercase text-gray-500 font-bold tracking-wider ml-1">Confirm</label>
                                        <input
                                            type="password"
                                            className="input-field"
                                            value={formData.confirmPassword}
                                            onChange={e => setFormData({ ...formData, confirmPassword: e.target.value })}
                                        />
                                    </div>
                                </div>

                                <button type="button" onClick={handleNext} className="btn-primary w-full mt-6">
                                    Next Step <ChevronRight size={20} />
                                </button>
                            </motion.div>
                        ) : (
                            <motion.div
                                initial={{ x: 20, opacity: 0 }}
                                animate={{ x: 0, opacity: 1 }}
                            >
                                <p className="text-gray-300 mb-6">Select topics you enjoy to personalize your experience:</p>
                                <div className="flex flex-wrap gap-3 mb-8">
                                    {interestsList.map(interest => (
                                        <button
                                            key={interest}
                                            type="button"
                                            onClick={() => toggleInterest(interest)}
                                            className={`px-4 py-2 rounded-full border text-sm transition-all duration-300 ${formData.interests.includes(interest)
                                                    ? 'bg-primary border-primary text-white shadow-[0_0_15px_rgba(109,40,217,0.4)]'
                                                    : 'bg-transparent border-white/20 text-gray-400 hover:border-white/50 hover:text-white'
                                                }`}
                                        >
                                            {interest}
                                        </button>
                                    ))}
                                </div>

                                <button type="submit" className="btn-primary w-full">
                                    Complete Registration
                                </button>
                                <button type="button" onClick={() => setStep(1)} className="w-full mt-4 text-gray-500 text-sm hover:text-white">
                                    Back to Step 1
                                </button>
                            </motion.div>
                        )}

                        <div className="text-center mt-6 border-t border-white/5 pt-4">
                            <span className="text-gray-500 text-sm">Already have an account? </span>
                            <button type="button" onClick={() => navigate('/login')} className="text-primary-light hover:text-white transition-colors text-sm font-bold">
                                Login
                            </button>
                        </div>
                    </form>
                </div>
            </motion.div>
        </div>
    );
}
