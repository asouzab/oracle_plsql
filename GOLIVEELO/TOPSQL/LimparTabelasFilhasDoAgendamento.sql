---------------------- DANGER ZONE ! -------------------------------
delete from elo_carteira where cd_elo_agendamento in (215,216);
delete from elo_agendamento_item where cd_elo_agendamento_supervisor in (
    select cd_elo_agendamento_supervisor from elo_agendamento_supervisor 
    where cd_elo_agendamento in (215,216)
)
;
delete from elo_agendamento_supervisor where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_PRIO_PANEL where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_PRIO_MATERIAL where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_CLI_RELAC where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_POLO_CENTRO where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_CENTRO_MACHINE where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_MACHINE_PROFIL where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_PROFILE_LINHA where cd_elo_agendamento in (215,216);
delete from ELO_AGENDAMENTO_CEN_GRP_EMB where cd_elo_agendamento in (215,216);