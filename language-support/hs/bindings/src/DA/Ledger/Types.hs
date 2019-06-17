-- Copyright (c) 2019 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DuplicateRecordFields #-}

-- These types offer the following benefits over the LowLevel types
--
-- (1) These types are human curated and intended for human consumption.
--     (The lowlevel types are generated by compile-proto, and have verbose record-field and constructor names.)
-- (2) These types are stronger: distinguishing various identifier classes, instead of everywhere being `Text`.
-- (3) These types capture required-field invariants.
-- (4) These types form a barrior against changes to names & representation in the .proto files.

module DA.Ledger.Types( -- High Level types for communication over Ledger API

    Commands(..),
    Command(..),
    Completion(..),
    Transaction(..),
    Event(..),
    Value(..),
    Record(..),
    RecordField(..),
    Variant(..),
    Identifier(..),
    Timestamp(..),
    Status, --(..), -- TODO

    MicroSecondsSinceEpoch(..),
    DaysSinceEpoch(..),
    TemplateId(..),
    LedgerId(..),
    TransactionId(..),
    EventId(..),
    ContractId(..),
    WorkflowId(..),
    ApplicationId(..),
    CommandId(..),
    PackageId(..),
    ConstructorId(..),
    VariantId(..),
    Choice(..),
    Party(..),
    ModuleName(..),
    EntityName(..),
    AbsOffset(..),

    ) where

import Data.Map (Map)
import Data.Text.Lazy (Text)
--import qualified Data.Text.Lazy as Text

-- commands.proto

data Commands = Commands {
    lid    :: LedgerId,
    wid    :: Maybe WorkflowId,
    aid    :: ApplicationId,
    cid    :: CommandId,
    party  :: Party,
    leTime :: Timestamp,
    mrTime :: Timestamp,
    coms   :: [Command] }

data Command
    = CreateCommand {
        tid  :: TemplateId,
        args :: Record }

    | ExerciseCommand {
        tid    :: TemplateId,
        cid    :: ContractId,
        choice :: Choice,
        arg    :: Value }

    | CreateAndExerciseCommand {
        tid        :: TemplateId,
        createArgs :: Record,
        choice     :: Choice,
        choiceArg  :: Value }
    deriving (Eq,Ord,Show)

-- completion.proto

data Completion
    = Completion {
        cid    :: CommandId,
        status :: Status }
    deriving (Eq,Ord,Show)

-- transaction.proto

data Transaction
    = Transaction {
        trid   :: TransactionId,
        cid    :: Maybe CommandId,
        wid    :: Maybe WorkflowId,
        leTime :: Timestamp,
        events :: [Event],
        offset :: AbsOffset } deriving (Eq,Ord,Show)

-- event.proto

data Event
    = CreatedEvent {
        eid        :: EventId,
        cid        :: ContractId,
        tid        :: TemplateId,
        createArgs :: Record,
        witness    :: [Party],
        key        :: Maybe Value }

    | ArchivedEvent {
        eid     :: EventId,
        cid     :: ContractId,
        tid     :: TemplateId,
        witness :: [Party] }
{-
    | ExercisedEvent {
        eid       :: EventId,
        cid       :: ContractId,
        tid       :: TemplateId,
        ccEid     :: EventId,
        choice    :: Choice,
        choiceArg :: Value,
        acting    :: [Party],
        consuming :: Bool,
        witness   :: [Party],
        childEids :: [EventId] }
-}
    deriving (Eq,Ord,Show)

-- value.proto

data Value
    = VRecord Record
    | VVariant Variant
    | VContract ContractId
    | VList [Value]
    | VInt Int
    | VDecimal Text -- TODO: Maybe use Haskell Decimal type
    | VString Text
    | VTimestamp MicroSecondsSinceEpoch
    | VParty Party
    | VBool Bool
    | VUnit
    | VDate DaysSinceEpoch
    | VOpt (Maybe Value)
    | VMap (Map Text Value)
    deriving (Eq,Ord,Show)

data Record
    = Record {
        rid    :: Maybe Identifier,
        fields :: [RecordField] } deriving (Eq,Ord,Show)

data RecordField
    = RecordField {
        label :: Text,
        fieldValue :: Value } deriving (Eq,Ord,Show)

data Variant
    = Variant {
        vid         :: VariantId,
        constructor :: ConstructorId,
        value       :: Value } deriving (Eq,Ord,Show)

data Identifier
    = Identifier {
        pid :: PackageId,
        mod :: ModuleName,
        ent :: EntityName } deriving (Eq,Ord,Show)

newtype MicroSecondsSinceEpoch = MicroSecondsSinceEpoch Int deriving (Eq,Ord,Show)-- TODO: Int64?
newtype DaysSinceEpoch = DaysSinceEpoch Int  deriving (Eq,Ord,Show)

data Timestamp
    = Timestamp {
        seconds :: Integer, -- TODO: Int64?
        nanos   :: Integer }  deriving (Eq,Ord,Show)

data Status = Status-- TODO: from standard google proto, determining success/failure
 deriving (Eq,Ord,Show)

newtype TemplateId = TemplateId Identifier -- TODO: remove this wrapping
    deriving (Eq,Ord,Show)

newtype LedgerId = LedgerId { unLedgerId :: Text } deriving (Eq,Ord,Show)

-- Text wrappers
newtype TransactionId = TransactionId { unTransactionId :: Text } deriving (Eq,Ord,Show)
newtype EventId = EventId { unEventId :: Text } deriving (Eq,Ord,Show)
newtype ContractId = ContractId { unContractId :: Text } deriving (Eq,Ord,Show)
newtype WorkflowId = WorkflowId { unWorkflowId :: Text } deriving (Eq,Ord,Show)
newtype ApplicationId = ApplicationId { unApplicationId :: Text } deriving (Eq,Ord,Show)
newtype CommandId = CommandId { unCommandId :: Text } deriving (Eq,Ord,Show)
newtype PackageId = PackageId { unPackageId :: Text } deriving (Eq,Ord,Show)
newtype ConstructorId = ConstructorId { unConstructorId :: Text } deriving (Eq,Ord,Show)
newtype VariantId = VariantId { unVariantId :: Text } deriving (Eq,Ord,Show)

newtype Choice = Choice { unChoice :: Text } deriving (Eq,Ord,Show)

newtype Party = Party { unParty :: Text } deriving (Eq,Ord,Show)
--instance Show Party where show = Text.unpack . unParty -- TODO: really?

newtype ModuleName = ModuleName { unModuleName :: Text } deriving (Eq,Ord,Show)
newtype EntityName = EntityName { unEntityName :: Text } deriving (Eq,Ord,Show)

newtype AbsOffset = AbsOffset { unAbsOffset :: Text }  deriving (Eq,Ord,Show) -- TODO: why not an int?

-- TODO: .proto message types not yet handled
{-
message Checkpoint {
message LedgerConfiguration {
message LedgerOffset {
message TraceContext {
message TransactionFilter {
message Filters {
message InclusiveFilters {
message TransactionTree {
message TreeEvent {
-}
