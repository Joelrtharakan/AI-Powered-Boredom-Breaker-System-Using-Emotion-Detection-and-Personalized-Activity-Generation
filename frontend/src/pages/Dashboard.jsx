import { useState } from 'react';
import { createPortal } from 'react-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Play, Music, Zap, Smile, Lock, Wind, Gamepad2, Mic, Book, BarChart2, MessageCircle, SkipForward } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

// Component for Quick Action Tiles
const QuickActionTile = ({ icon: Icon, title, desc, onClick, delay }) => (
    <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: delay * 0.1 }}
        onClick={onClick}
        className="glass-card p-6 flex flex-col items-center justify-center gap-4 cursor-pointer group hover:bg-white/50"
    >
        <div className="w-14 h-14 rounded-2xl bg-slate-50 flex items-center justify-center group-hover:scale-110 transition-transform duration-300 shadow-sm group-hover:shadow-md">
            <Icon size={28} className="text-primary group-hover:text-primary-dark transition-colors" />
        </div>
        <div className="text-center">
            <h3 className="font-bold text-lg mb-1 text-txt-main">{title}</h3>
            <p className="text-xs text-txt-muted font-medium uppercase tracking-wider">{desc}</p>
        </div>
    </motion.div>
);

export default function Dashboard() {
    const navigate = useNavigate();
    const { user, logout } = useAuth();
    const [moodText, setMoodText] = useState('');
    const [loading, setLoading] = useState(false);
    const [suggestion, setSuggestion] = useState(null);
    const [showModal, setShowModal] = useState(false);
    const [modalMessage, setModalMessage] = useState('');

    const handleDetect = async () => {
        if (!moodText || !user) return;
        setLoading(true);
        const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';
        try {
            // 1. Detect Mood
            const moodRes = await axios.post(`${API_URL}/mood/detect`, { text: moodText });
            const moodData = moodRes.data;

            // Check for neutral/ambiguous input
            if (moodData.emotion === 'neutral') {
                setModalMessage("✨ No specific emotion detected. Try describing how you feel in more detail!");
                setShowModal(true);
                setLoading(false);
                return;
            }

            // INSTANT FEEDBACK: Show detected mood while generating plan
            setSuggestion({
                mood: moodData.mood,
                intensity: moodData.intensity,
                plan: [] // Empty plan serves as loading state
            });

            // 2. Get Suggestion Plan
            const planRes = await axios.post(`${API_URL}/suggest/`, {
                user_id: user.id,
                mood: moodData.mood,
                emotion: moodData.emotion,
                intensity: moodData.intensity,
                time_available_minutes: 30,
                preferences: {}
            });

            setSuggestion({
                mood: moodData.mood,
                intensity: moodData.intensity,
                plan: planRes.data.plan
            });

            // 3. Log Mood (Async)
            await axios.post(`${API_URL}/mood/log?user_id=${user.id}`, {
                mood: moodData.mood,
                intensity: moodData.intensity,
                activities_used: []
            });

        } catch (e) {
            console.error(e);
            setModalMessage("Failed to analyze mood. Please try again.");
            setShowModal(true);
        } finally {
            setLoading(false);
        }
    };

    const handleSurprise = async () => {
        const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';
        try {
            const res = await axios.get(`${API_URL}/suggest/surprise`);
            setModalMessage(`Surprise! ${res.data.type}: ${JSON.stringify(res.data.payload)}`);
            setShowModal(true);
        } catch (e) { console.error(e); }
    }

    return (
        <div className="pt-10 px-4 pb-20 max-w-5xl mx-auto space-y-12">

            {/* A. Mood Input Section */}
            <section className="relative">
                <div className="absolute inset-0 bg-primary/5 blur-[100px] -z-10" />
                <div className="glass-card p-1 relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-primary to-transparent opacity-50" />
                    <div className="p-8 md:p-12 flex flex-col items-center text-center gap-8">
                        <div>
                            <h2 className="text-3xl md:text-5xl font-light text-txt-main mb-2">How are you feeling?</h2>
                            <p className="text-txt-muted">Tell me or just click the magic button.</p>
                        </div>

                        <div className="w-full max-w-3xl relative group">
                            <textarea
                                value={moodText}
                                onChange={(e) => setMoodText(e.target.value)}
                                placeholder="I'm feeling a bit bored and tired..."
                                className="w-full bg-white border border-slate-200 rounded-3xl p-6 md:p-8 text-xl md:text-2xl text-txt-main placeholder-slate-400 focus:outline-none focus:border-primary/50 transition-all resize-none shadow-sm min-h-[160px]"
                            />
                            <div className="absolute bottom-6 right-6 flex gap-3">
                                <button className="p-3 rounded-full bg-slate-50 hover:bg-slate-100 text-slate-400 hover:text-slate-600 transition-all hover:scale-110">
                                    <Mic size={24} />
                                </button>
                            </div>
                        </div>

                        <div className="flex flex-wrap gap-4 justify-center w-full">
                            <button
                                onClick={handleDetect}
                                disabled={loading}
                                className="btn-primary min-w-[200px] py-4 text-lg shadow-neon-blue/20"
                            >
                                {loading ? <Zap className="animate-spin" /> : <Sparkles />}
                                {loading ? "Analyzing..." : "Detect Mood"}
                            </button>

                            <button
                                onClick={handleSurprise}
                                className="px-8 py-4 rounded-xl border border-slate-200 hover:bg-slate-50 text-txt-muted font-medium transition-colors bg-gradient-to-tr from-yellow-400/5 to-orange-500/5 hover:text-txt-main"
                            >
                                Surprise Me 🎁
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            {/* B. Suggested Plan Card */}
            <AnimatePresence>
                {suggestion && (
                    <motion.section
                        initial={{ opacity: 0, scale: 0.95, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        className="glass-card border border-primary/30 p-8 md:p-10 relative overflow-hidden"
                    >
                        {/* Glow effects */}
                        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-primary/10 rounded-full blur-[100px] -translate-y-1/2 translate-x-1/2 -z-10" />

                        <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div>
                                <h3 className="text-sm uppercase tracking-widest text-primary font-bold mb-2">Analysis Complete</h3>
                                <div className="text-3xl md:text-4xl font-bold text-txt-main capitalize flex items-center gap-3">
                                    {suggestion.mood} <span className="text-lg font-normal text-txt-muted bg-slate-100 px-3 py-1 rounded-full">{Math.round((suggestion.intensity || 0) * 100)}% Intensity</span>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <button className="p-3 rounded-xl hover:bg-slate-100 transition-colors"><SkipForward size={24} /></button>
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                            {suggestion.plan && suggestion.plan.length > 0 ? (
                                suggestion.plan.map((item, i) => (
                                    <motion.div
                                        key={i}
                                        initial={{ opacity: 0, x: -20 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        transition={{ delay: i * 0.1 }}
                                        onClick={() => {
                                            if (item.type === 'breathing') navigate('/zen');
                                            if (item.type === 'game') navigate('/games');
                                            if (item.type === 'music') {
                                                const moodParam = suggestion.mood ? `&mood=${suggestion.mood}` : '';
                                                if (item.spotify_uri) {
                                                    navigate(`/music?uri=${encodeURIComponent(item.spotify_uri)}${moodParam}`);
                                                } else {
                                                    navigate(`/music${suggestion.mood ? `?mood=${suggestion.mood}` : ''}`);
                                                }
                                            }
                                            if (item.type === 'micro_task') navigate('/dashboard');
                                        }}
                                        className={`bg-white border border-slate-100 shadow-sm p-6 rounded-2xl hover:bg-slate-50 transition-colors flex flex-col gap-3 group ${['breathing', 'game', 'music'].includes(item.type) ? 'cursor-pointer hover:border-primary/50 ring-1 ring-transparent hover:ring-primary/30' : ''
                                            }`}
                                    >
                                        <div className="p-3 bg-slate-100 rounded-xl w-fit group-hover:scale-110 transition-transform duration-300">
                                            <PlanIcon type={item.type} />
                                        </div>
                                        <div className="text-xs text-primary-glow font-bold uppercase tracking-wider">{item.type.replace('_', ' ')}</div>
                                        <div className="font-medium text-lg leading-snug">{item.description}</div>
                                        {item.time_minutes && <div className="mt-auto text-sm text-gray-500">{item.time_minutes} min</div>}
                                    </motion.div>
                                ))
                            ) : (
                                <div className="col-span-full py-12 flex flex-col items-center justify-center text-gray-400 gap-4">
                                    <Zap className="animate-spin text-primary-glow" size={32} />
                                    <p className="animate-pulse">Crafting your perfect boredom cure...</p>
                                </div>
                            )}
                        </div>
                    </motion.section>
                )}
            </AnimatePresence>

            {/* C. Explore More Tiles */}
            <section>
                <div className="flex items-center justify-between mb-6">
                    <h3 className="text-xl text-txt-main font-light">Explore More</h3>
                    <div className="h-[1px] flex-1 bg-slate-200 ml-6" />
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <QuickActionTile
                        icon={Wind}
                        title="Zen Mode"
                        desc="Breathe & Relax"
                        onClick={() => navigate('/zen')}
                        delay={0}
                    />
                    <QuickActionTile
                        icon={Gamepad2}
                        title="Arcade"
                        desc="Play Games"
                        onClick={() => navigate('/games')}
                        delay={1}
                    />
                    <QuickActionTile
                        icon={MessageCircle}
                        title="AI Friend"
                        desc="Chat & Vent"
                        onClick={() => navigate('/chat')}
                        delay={2}
                    />
                    <QuickActionTile
                        icon={Music}
                        title="Vibe Check"
                        desc="Music"
                        onClick={() => navigate('/music')}
                        delay={3}
                    />
                </div>
            </section>

            {/* Custom Modal - Portalled to Body */}
            {createPortal(
                <AnimatePresence>
                    {showModal && (
                        <motion.div
                            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                            className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60"
                            onClick={() => setShowModal(false)}
                        >
                            <motion.div
                                initial={{ scale: 0.8, opacity: 0, y: 50 }}
                                animate={{ scale: 1, opacity: 1, y: 0 }}
                                exit={{ scale: 0.8, opacity: 0, y: 50 }}
                                transition={{ type: "spring", damping: 25, stiffness: 400 }}
                                className="bg-white border border-slate-200 p-8 rounded-3xl max-w-md w-full shadow-2xl relative overflow-hidden"
                                onClick={e => e.stopPropagation()}
                            >
                                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-primary to-transparent" />
                                <div className="flex flex-col items-center text-center gap-4">
                                    <div className="w-16 h-16 rounded-full bg-slate-50 flex items-center justify-center mb-2">
                                        <Sparkles size={32} className="text-primary" />
                                    </div>
                                    <h3 className="text-xl font-bold text-txt-main">Hey there!</h3>
                                    <p className="text-txt-muted">{modalMessage}</p>
                                    <button
                                        onClick={() => setShowModal(false)}
                                        className="mt-4 px-8 py-3 rounded-xl bg-primary hover:bg-primary-glow text-white font-medium transition-all w-full"
                                    >
                                        Got it
                                    </button>
                                </div>
                            </motion.div>
                        </motion.div>
                    )}
                </AnimatePresence>,
                document.body
            )}
        </div>
    );
}

// Subcomponents
const UserAvatar = () => (
    <div className="w-full h-full rounded-full bg-gradient-to-tr from-primary to-neon-blue p-[2px]">
        <div className="w-full h-full rounded-full bg-surface flex items-center justify-center font-bold text-sm">
            ME
        </div>
    </div>
);

const PlanIcon = ({ type }) => {
    switch (type) {
        case 'breathing': return <Wind size={20} className="text-cyan-400" />;
        case 'micro_task': return <Zap size={20} className="text-yellow-400" />;
        case 'activity': return <Sparkles size={20} className="text-purple-400" />;
        case 'music': return <Music size={20} className="text-pink-400" />;
        case 'game': return <Gamepad2 size={20} className="text-orange-400" />;
        default: return <Smile size={20} className="text-green-400" />;
    }
}
