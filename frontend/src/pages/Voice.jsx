import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Mic, MicOff, X, Volume2, RotateCcw } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export default function Voice() {
    const navigate = useNavigate();
    const { user } = useAuth();
    const [isListening, setIsListening] = useState(false);
    const [isSpeaking, setIsSpeaking] = useState(false);
    const [transcript, setTranscript] = useState("Tap microphone to chat");
    const [response, setResponse] = useState("");
    const recognitionRef = useRef(null);
    const silenceTimer = useRef(null);

    useEffect(() => {
        // Initialize Speech Recognition
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            recognitionRef.current = new SpeechRecognition();
            recognitionRef.current.continuous = false; // Stop after one phrase
            recognitionRef.current.interimResults = true;

            recognitionRef.current.onstart = () => {
                setIsListening(true);
                setTranscript("Listening...");
            };

            recognitionRef.current.onresult = (event) => {
                const current = event.resultIndex;
                const transcriptText = event.results[current][0].transcript;
                setTranscript(transcriptText);

                // Auto-stop detection if silence (optional, but continuous=false handles most)
                if (silenceTimer.current) clearTimeout(silenceTimer.current);
                silenceTimer.current = setTimeout(() => {
                    if (recognitionRef.current && isListening) recognitionRef.current.stop();
                }, 2000);
            };

            recognitionRef.current.onend = () => {
                setIsListening(false);
                // Auto-submit on end if we have content
                setTranscript(prev => {
                    if (prev && prev !== "Listening..." && prev !== "Tap microphone to chat") {
                        processVoiceInput(prev);
                    }
                    return prev;
                });
            };

            // Handle actual processing in a separate logic flow triggered by the end event or state
        } else {
            setTranscript("Browser does not support Speech Recognition.");
        }

        return () => {
            if (recognitionRef.current) recognitionRef.current.stop();
            window.speechSynthesis.cancel();
        };
    }, []);

    const processVoiceInput = async (text) => {
        if (!text || text === "Listening..." || text === "Tap microphone to chat") return;

        try {
            setResponse("Thinking...");
            // Send to backend
            const formData = new FormData();
            formData.append('transcript', text);
            if (user) formData.append('user_id', user.id);

            const res = await axios.post(`${API_URL}/chat`, formData);

            const aiReply = res.data.reply;
            setResponse(aiReply);
            speak(aiReply);
        } catch (e) {
            console.error(e);
            setResponse("Sorry, I had trouble connecting.");
            speak("Sorry, I had trouble connecting.");
        }
    };

    const speak = (text) => {
        if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel(); // Stop overlap

            const utter = () => {
                const utterance = new SpeechSynthesisUtterance(text);
                utterance.rate = 1.0;
                utterance.pitch = 1.0;

                // Prefer a specific pleasant voice
                const voices = window.speechSynthesis.getVoices();
                // Priority: Google UK English Female -> Any customized female voice -> Google US English -> Default
                const preferredVoice =
                    voices.find(v => v.name.includes('Google UK English Female')) ||
                    voices.find(v => v.name.includes('Google US English')) ||
                    voices.find(v => v.name.includes('Samantha')) ||
                    voices.find(v => v.lang.startsWith('en'));

                if (preferredVoice) utterance.voice = preferredVoice;

                utterance.onstart = () => setIsSpeaking(true);
                utterance.onend = () => setIsSpeaking(false);
                utterance.onerror = (e) => {
                    console.error("TTS Error:", e);
                    setIsSpeaking(false);
                };

                window.speechSynthesis.speak(utterance);
            };

            if (window.speechSynthesis.getVoices().length === 0) {
                window.speechSynthesis.onvoiceschanged = utter;
            } else {
                utter();
            }
        }
    };

    const toggleListen = () => {
        if (!recognitionRef.current) return;

        if (isListening) {
            recognitionRef.current.stop();
        } else {
            window.speechSynthesis.cancel();
            setResponse("");
            setTranscript("Listening...");
            recognitionRef.current.start();
        }
    };

    return (
        <div className="fixed inset-0 bg-black z-50 flex flex-col items-center justify-center overflow-hidden font-sans">
            {/* Ambient Background */}
            <div className={`absolute inset-0 transition-opacity duration-1000 ${isSpeaking ? 'opacity-30' : 'opacity-10'} bg-gradient-to-tr from-purple-900 to-blue-900`} />

            {/* Visualizer Circles */}
            {isListening && [...Array(3)].map((_, i) => (
                <motion.div
                    key={i}
                    initial={{ scale: 1, opacity: 0.5 }}
                    animate={{ scale: 2, opacity: 0 }}
                    transition={{ duration: 1.5, repeat: Infinity, delay: i * 0.4 }}
                    className="absolute rounded-full border border-primary/50"
                    style={{ width: '200px', height: '200px' }}
                />
            ))}

            {isSpeaking && [...Array(3)].map((_, i) => (
                <motion.div
                    key={`speak-${i}`}
                    initial={{ scale: 1, opacity: 0.5 }}
                    animate={{ scale: 2.5, opacity: 0 }}
                    transition={{ duration: 2, repeat: Infinity, delay: i * 0.3 }}
                    className="absolute rounded-full border-2 border-cyan-400/30"
                    style={{ width: '150px', height: '150px' }}
                />
            ))}

            <button onClick={() => navigate('/dashboard')} className="absolute top-8 right-8 p-3 rounded-full bg-white/10 hover:bg-white/20 transition-colors z-50 backdrop-blur-md">
                <X size={24} className="text-white" />
            </button>

            <div className="relative z-10 flex flex-col items-center w-full max-w-2xl px-6">

                {/* AI Response Area */}
                <div className="min-h-[120px] flex items-center justify-center mb-12">
                    <AnimatePresence mode="wait">
                        {response && (
                            <motion.div
                                key="response"
                                initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}
                                className="text-center"
                            >
                                <p className="text-2xl md:text-3xl font-light text-cyan-100 leading-relaxed shadow-black drop-shadow-lg">
                                    "{response}"
                                </p>
                            </motion.div>
                        )}
                    </AnimatePresence>
                </div>

                {/* Mic Button */}
                <motion.button
                    onClick={toggleListen}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    animate={{
                        boxShadow: isListening
                            ? "0 0 50px rgba(139,92,246,0.5)"
                            : isSpeaking
                                ? "0 0 50px rgba(34,211,238,0.5)"
                                : "0 0 0px rgba(0,0,0,0)"
                    }}
                    className={`w-32 h-32 md:w-40 md:h-40 rounded-full flex items-center justify-center transition-all duration-300 relative z-20 
                        ${isListening ? 'bg-gradient-to-tr from-violet-600 to-indigo-600' : isSpeaking ? 'bg-gradient-to-tr from-cyan-600 to-blue-600' : 'bg-slate-800 border border-white/10'}
                    `}
                >
                    {isListening ? (
                        <Mic size={56} className="text-white animate-pulse" />
                    ) : isSpeaking ? (
                        <Volume2 size={56} className="text-white animate-pulse" />
                    ) : (
                        <MicOff size={48} className="text-gray-400" />
                    )}
                </motion.button>

                {/* User Transcript */}
                <div className="mt-12 h-20 text-center">
                    <p className={`text-xl font-light transition-colors ${isListening ? 'text-white' : 'text-gray-500'}`}>
                        {transcript}
                    </p>
                </div>
            </div>
        </div>
    );
}
